!
! Manager for ``derived_type``'s ``DerivedType`` derived type
!
! In combination with ``derived_type_w``,
! this allows the ``DerivedType`` derived type
! to be exposed to Python.
!
module derived_type_manager

    use derived_type, only: DerivedType
    use fgen_utils, only: &
        finalize_derived_type_instance_number, &
        get_derived_type_free_instance_number

    implicit none
    private

    integer, parameter :: N_INSTANCES = 4096

    type(DerivedType), target, dimension(N_INSTANCES) :: instance_array
    logical, dimension(N_INSTANCES) :: instance_available = .true.

    public :: get_free_instance_number, &
              get_instance, &
              instance_finalize

contains

    function get_free_instance_number() result(instance_index)
        ! Get the index of a free instance

        integer :: instance_index
        ! Free instance index

        call get_derived_type_free_instance_number( &
            instance_index, &
            N_INSTANCES, &
            instance_available, &
            instance_array &
            )

    end function get_free_instance_number

    subroutine get_instance(instance_index, instance_pointer)
        ! Associate a pointer with the instance corresponding to the given model index
        !
        ! Stops execution if the instance has not already been initialised.

        integer, intent(in) :: instance_index
        ! Index of the instance to point to

        type(DerivedType), pointer, intent(inout) :: instance_pointer
        ! Pointer to associate

        call check_index_claimed(instance_index)
        instance_pointer => instance_array(instance_index)

    end subroutine get_instance

    subroutine instance_finalize(instance_index)
        ! Finalise an instance

        integer, intent(in) :: instance_index
        ! Index of the instance to finalise

        call check_index_claimed(instance_index)
        call finalize_derived_type_instance_number( &
            instance_index, &
            N_INSTANCES, &
            instance_available, &
            instance_array &
            )

    end subroutine instance_finalize

    subroutine check_index_claimed(instance_index)
        ! Check that an index has already been claimed
        !
        ! Stops execution if the index has not been claimed.

        integer, intent(in) :: instance_index
        ! Instance index to check

        if (instance_available(instance_index)) then
            print *, "Index ", instance_index, " has not been claimed"
            error stop 1
        end if

        if (instance_index < 1) then
            ! TODO: return error code to python
            print *, "Requested index is ", instance_index, " which is less than 1"
            error stop 1
        end if

        if (instance_array(instance_index) % instance_index < 1) then
            ! TODO: return error code to python
            print *, "Index ", instance_index, " is associated with an instance that has instance index < 1", &
                "instance's instance_index attribute ", instance_array(instance_index) % instance_index
            error stop 1
        end if

    end subroutine check_index_claimed

end module derived_type_manager
