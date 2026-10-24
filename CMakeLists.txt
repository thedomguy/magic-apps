cmake_minimum_required(VERSION 3.20)
project(magic-apps NONE)

# Usage: cmake -S . -B build && cmake --build build --target load-apps
# Apps come from apps.cmake. Per-app targets: load-<name>. Override the phone with DEVICE_ID=<id>.
include(apps.cmake)

set(_loaders "")
foreach(entry IN LISTS MAGIC_APPS)
  string(REPLACE "|" ";" entry "${entry}")
  list(GET entry 0 name)
  list(GET entry 1 dir)
  list(GET entry 2 bundle)
  list(GET entry 3 launch)
  add_custom_target(load-${name}
    COMMAND ${CMAKE_SOURCE_DIR}/scripts/load-app.sh ${dir} ${name} ${bundle} ${launch}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    USES_TERMINAL
    COMMENT "Loading ${name} onto the iPhone")
  list(APPEND _loaders load-${name})
endforeach()

# Serialize: concurrent xcodebuilds fight over the device and signing.
add_custom_target(load-apps COMMENT "All configured apps loaded")
set(_prev "")
foreach(t IN LISTS _loaders)
  if(_prev)
    add_dependencies(${t} ${_prev})
  endif()
  add_dependencies(load-apps ${t})
  set(_prev ${t})
endforeach()
