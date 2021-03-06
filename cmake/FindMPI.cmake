# - Find MPI
# This module looks for MPI (Message Passing Interface) support
# Sets:
# MPI_INCLUDE_DIR  = where MPI headers can be found
# MPI_LIBRARY      = the library to link against
# SF_HAVE_MPI      = set to true after finding the library
#

SET_TRIAL_INCLUDE_PATH ("") # clear include search path
SET_TRIAL_LIBRARY_PATH ("") # clear library search path

# try in user defined paths first
ADD_TRIAL_INCLUDE_PATH( ${MPI_HOME}/include )
ADD_TRIAL_INCLUDE_PATH( $ENV{MPI_HOME}/include )
FIND_PATH(MPI_INCLUDE_DIR
          NAMES mpi.h
          PATH_SUFFIXES mpi mpi/include
          PATHS
          ${TRIAL_INCLUDE_PATHS}  NO_DEFAULT_PATH )

# try in these paths first and then the system ones
IF ( NOT MPI_INCLUDE_DIR )
  FIND_PATH(MPI_INCLUDE_DIR
            NAMES mpi.h
            PATH_SUFFIXES mpi mpi/include
            PATHS
            /usr/local
            /usr/local/include
            /usr/include
            "$ENV{ProgramFiles}/MPICH/SDK/Include"
            "$ENV{ProgramFiles}/MPICH2/include"
            "C:/Program Files/MPICH/SDK/Include" )
ENDIF()

ADD_TRIAL_LIBRARY_PATH(${MPI_HOME}/lib )
ADD_TRIAL_LIBRARY_PATH($ENV{MPI_HOME}/lib )

FIND_LIBRARY(MPI_LIBRARY
             NAMES mpich2 mpi mpich mpich.rts mpt mvapich2
             PATH_SUFFIXES mpi/lib
             PATHS ${TRIAL_LIBRARY_PATHS} NO_DEFAULT_PATH )

IF ( NOT MPI_LIBRARY )
  FIND_LIBRARY(MPI_LIBRARY
               NAMES mpich2 mpi mpich mpich.rts mpt mvapich2
               PATH_SUFFIXES mpi/lib
               PATHS /usr/lib /usr/local/lib
               "$ENV{ProgramFiles}/MPICH/SDK/Lib"
               "$ENV{ProgramFiles}/MPICH2/Lib"
               "C:/Program Files/MPICH/SDK/Lib" )
ENDIF()

# search for the mpi c++ library
FIND_LIBRARY(MPICXX_LIBRARY
             NAMES mpi++ mpi_cxx
             PATH_SUFFIXES mpi/lib
             PATHS ${TRIAL_LIBRARY_PATHS} NO_DEFAULT_PATH)


IF ( NOT MPICXX_LIBRARY )
  FIND_LIBRARY(MPICXX_LIBRARY
               NAMES mpi++ mpi_cxx
               PATH_SUFFIXES mpi/lib
               PATHS /usr/lib /usr/local/lib
               "$ENV{ProgramFiles}/MPICH/SDK/Lib"
               "$ENV{ProgramFiles}/MPICH2/Lib"
               "C:/Program Files/MPICH/SDK/Lib" )
ENDIF()

IF ( MPICXX_LIBRARY )
  LIST ( APPEND MPI_LIBRARIES ${MPICXX_LIBRARY} )
ENDIF()
IF ( MPI_LIBRARY )
  LIST ( APPEND MPI_LIBRARIES ${MPI_LIBRARY} )
ENDIF()

IF ( DEFINED MPI_EXTRA_LIBRARY_NAMES )
  
  FOREACH( mpi_extra_lib ${MPI_EXTRA_LIBRARY_NAMES} )
    
    # try in user defined paths first
    FIND_LIBRARY( MPI_EXTRA_LIBRARY_${mpi_extra_lib}
      NAMES ${mpi_extra_lib}
      PATH_SUFFIXES mpi/lib
      PATHS ${TRIAL_LIBRARY_PATHS} NO_DEFAULT_PATH)
    
    # try in these paths first and then the system ones
    FIND_LIBRARY( MPI_EXTRA_LIBRARY_${mpi_extra_lib}
      NAMES ${mpi_extra_lib}
      PATHS /usr/lib /usr/local/lib
      "$ENV{ProgramFiles}/MPICH/SDK/Lib"
      "$ENV{ProgramFiles}/MPICH2/Lib"
      "C:/Program Files/MPICH/SDK/Lib" )
    
    MARK_AS_ADVANCED ( MPI_EXTRA_LIBRARY_${mpi_extra_lib} )
    
#    SF_DEBUG_VAR ( ${mpi_extra_lib} )
#    SF_DEBUG_VAR ( MPI_EXTRA_LIBRARY_${mpi_extra_lib} )
    
    IF ( NOT MPI_EXTRA_LIBRARY_${mpi_extra_lib} )
      MESSAGE ( FATAL_ERROR "User defined MPI extra lib \'${mpi_extra_lib}\' NOT FOUND" )
    ELSE()
      LIST ( APPEND MPI_EXTRA_LIBS ${MPI_EXTRA_LIBRARY_${mpi_extra_lib}} )
      MARK_AS_ADVANCED( MPI_EXTRA_LIBS )
    ENDIF()
    
  ENDFOREACH( mpi_extra_lib )
  
  LIST ( APPEND MPI_LIBRARIES ${MPI_EXTRA_LIBS} )
  
ENDIF()

IF ( MPI_INCLUDE_DIR AND MPI_LIBRARY )
  SET(SF_HAVE_MPI 1 CACHE BOOL "Found MPI library")
ELSE()
  SET(SF_HAVE_MPI 0 CACHE BOOL "Not found MPI library")
ENDIF()

MARK_AS_ADVANCED(
  MPI_INCLUDE_DIR
  MPI_LIBRARY
  MPICXX_LIBRARY
  MPI_LIBRARIES
  SF_HAVE_MPI
)

IF ( SF_HAVE_MPI )
  INCLUDE_DIRECTORIES(${MPI_INCLUDE_DIR})
ENDIF()

LOG ( "  SF_HAVE_MPI        : [${SF_HAVE_MPI}]" )
LOG ( "  MPI_INCLUDE_DIR    : [${MPI_INCLUDE_DIR}]" )
LOG ( "  MPI_LIBRARY        : [${MPI_LIBRARY}]" )
LOG ( "  MPICXX_LIBRARY     : [${MPICXX_LIBRARY}]" )
LOG ( "  MPI_EXTRA_LIBS     : [${MPI_EXTRA_LIBS}]" )
LOG ( "  MPI_LIBRARIES      : [${MPI_LIBRARIES}]" )

