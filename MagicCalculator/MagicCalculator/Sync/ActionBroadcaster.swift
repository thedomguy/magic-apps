import Foundation

/// Turns calculator input into the event stream the peek app follows: profile loaded, each number
/// as its operator is pressed, the operators, `=` with the result, plus the profile's field capture.
///
/// A session is one calculation, opened by a profile load or the first action after the last one
/// ended. It ends on `=` or AC.
struct ActionBroadcaster {
    private var session = UUID()
    private var seq = 0
    /// Set once `=`/AC closes the session, so the next action opens a fresh one.
    private var ended = false
    private var capture = ProfileCapture()

    mutating func profileLoaded(_ profile: Profile) -> [BroadcastEvent] {
        startSession()
        capture.reset()
        var event = make(.profile, profile)
        event.fields = profile.fields.indices.map {
            FieldValue(label: profile.displayLabel(at: $0), digitCount: profile.fields[$0].digitCount)
        }
        // Left open: the calculation that follows belongs to this profile load.
        return [event]
    }

    mutating func captureTurnedOff(_ profile: Profile) -> [BroadcastEvent] {
        startSession()
        capture.reset()
        let event = make(.off, profile)
        ended = true
        return [event]
    }

    /// For profile changes made outside the calculator (backstage), which aren't broadcast.
    mutating func reset() {
        capture.reset()
        ended = true
    }

    mutating func handle(_ input: CalculatorEngine.InputEvent, profile: Profile) -> [BroadcastEvent] {
        switch input {
        case .changed(let operands):
            return captured(capture.update(operands: operands, profile: profile), profile)

        case let .operation(symbol, index, number, expression):
            var events: [BroadcastEvent] = []
            if let number {
                events.append(numberEvent(number, profile, expression: expression))
            }
            var op = make(.operation, profile)
            op.index = index
            op.value = symbol
            op.expression = expression
            events.append(op)
            return events

        case let .equals(number, operands, expression, result):
            var events: [BroadcastEvent] = []
            if let number {
                events.append(numberEvent(number, profile, expression: expression))
            }
            events += captured(capture.commit(operands: operands, profile: profile), profile)
            var equals = make(.equals, profile)
            equals.value = result
            equals.expression = expression
            events.append(equals)
            ended = true
            return events

        case .cleared:
            capture.reset()
            // Nothing to close when the session has no actions yet (or AC fired twice).
            guard !ended, seq > 0 else { return [] }
            let event = make(.clear, profile)
            ended = true
            return [event]
        }
    }

    // MARK: - Internals

    private mutating func numberEvent(
        _ number: CalculatorEngine.ClosedNumber,
        _ profile: Profile,
        expression: String
    ) -> BroadcastEvent {
        var event = make(.number, profile)
        event.index = number.index
        event.value = number.text
        event.expression = expression
        return event
    }

    private mutating func captured(_ result: CapturedFields?, _ profile: Profile) -> [BroadcastEvent] {
        guard let result else { return [] }
        var event = make(.capture, profile)
        event.fields = result.fields
        event.complete = result.complete
        return [event]
    }

    private mutating func startSession() {
        session = UUID()
        seq = 0
        ended = false
    }

    private mutating func make(_ type: BroadcastEvent.Kind, _ profile: Profile) -> BroadcastEvent {
        if ended { startSession() }
        seq += 1
        return BroadcastEvent(
            session: session,
            seq: seq,
            type: type,
            profile: .init(slot: profile.slot, name: profile.displayName)
        )
    }
}
