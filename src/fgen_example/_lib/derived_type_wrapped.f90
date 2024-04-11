!!!
! Wrapper for ``derived_type``
!
! In combination with ``derived_type_manager``,
! this allows the ``DerivedType`` derived type
! to be exposed to Python.
!!!
module derived_type_w

    ! Standard library requirements
    use iso_c_binding, only: c_loc, c_ptr

    ! First-party requirements from the module we're wrapping
    use derived_type, only: DerivedType
    use derived_type_manager, only: &
        manager_get_free_instance => get_free_instance_number, &
        manager_instance_finalize => instance_finalize, &
        manager_get_instance => get_instance

    implicit none
    private

    public :: get_free_instance_number, &
              instance_build, &
              instance_finalize

    ! Statment declarations for getters and setters
    public :: iget_base
    public :: iset_base

    ! Statement declarations for methods
    public :: i_add
    public :: i_double

contains

    function get_free_instance_number() result(instance_index)

        integer :: instance_index

        instance_index = manager_get_free_instance()

    end function get_free_instance_number

    ! Build methods
    !
    ! These are a bit like Python class methods,
    ! but they build/intialise/set up the class
    ! rather than returning a new instance.
    subroutine instance_build( &
        instance_index, &
        base &
        )

        integer, intent(in) :: instance_index

        real(8), intent(in) :: base
        ! Passing of base

        type(DerivedType), pointer :: instance

        call manager_get_instance(instance_index, instance)

        call instance % build( &
            base=base &
            )

    end subroutine instance_build

    ! Finalisation
    subroutine instance_finalize(instance_index)

        integer, intent(in) :: instance_index

        call manager_instance_finalize(instance_index)

    end subroutine instance_finalize

    ! Attributes getters and setters
    ! Wrapping base
    ! Strategy: WrappingStrategyDefault(
    !     magnitude_suffix='_m',
    ! )
    subroutine iget_base( &
        instance_index, &
        base &
        )

        integer, intent(in) :: instance_index

        real(8), intent(out) :: base
        ! Returning of base

        type(DerivedType), pointer :: instance

        call manager_get_instance(instance_index, instance)

        base = instance % base

    end subroutine iget_base

    subroutine iset_base( &
        instance_index, &
        base &
        )

        integer, intent(in) :: instance_index

        real(8), intent(in) :: base
        ! Passing of base

        type(DerivedType), pointer :: instance

        call manager_get_instance(instance_index, instance)

        instance % base = base

    end subroutine iset_base

    ! Wrapped methods
    ! Wrapping output
    ! Strategy: WrappingStrategyDefault(
    !     magnitude_suffix='_m',
    ! )
    subroutine i_add( &
        instance_index, &
        other, &
        output &
        )

        integer, intent(in) :: instance_index

        real(8), intent(in) :: other
        ! Passing of other

        real(8), intent(out) :: output
        ! Returning of output

        type(DerivedType), pointer :: instance

        call manager_get_instance(instance_index, instance)

        output = instance % add( &
                 other=other &
                 )

    end subroutine i_add

    ! Wrapping output
    ! Strategy: WrappingStrategyDefault(
    !     magnitude_suffix='_m',
    ! )
    subroutine i_double( &
        instance_index, &
        output &
        )

        integer, intent(in) :: instance_index

        real(8), intent(out) :: output
        ! Returning of output

        type(DerivedType), pointer :: instance

        call manager_get_instance(instance_index, instance)

        output = instance % double( &
                 )

    end subroutine i_double

end module derived_type_w
