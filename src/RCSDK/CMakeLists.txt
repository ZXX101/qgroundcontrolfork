target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        RCSignalQualityManager.cc
        RCSignalQualityManager.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
