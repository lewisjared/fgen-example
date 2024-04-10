!!!
! Wrapper for ``operations``
!
! In combination with ``operations_manager``,
! this allows the ``Operator`` derived type
! to be exposed to Python.
!!!
module operations_w

   ! Standard library requirements
   use iso_c_binding, only: c_loc, c_ptr

   ! First-party requirements from the module we're wrapping
   use operations, only: Operator
   use operations_manager, only: &
      manager_get_free_instance => get_free_instance_number, &
      manager_instance_finalize => instance_finalize, &
      manager_get_instance => get_instance

   implicit none
   private

   public :: get_free_instance_number, &
             instance_build, &
             instance_finalize

   ! Statment declarations for getters and setters
   public :: iget_weight
   public :: iset_weight

   ! Statement declarations for methods
   public :: i_calc_vec_prod_sum

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
      weight &
      )

      integer, intent(in) :: instance_index

      real(8), intent(in) :: weight
      ! Passing of weight

      type(Operator), pointer :: instance

      call manager_get_instance(instance_index, instance)

      call instance%build( &
         weight=weight &
         )

   end subroutine instance_build

   ! Finalisation
   subroutine instance_finalize(instance_index)

      integer, intent(in) :: instance_index

      call manager_instance_finalize(instance_index)

   end subroutine instance_finalize

   ! Attributes getters and setters
   ! Wrapping weight
   ! Strategy: WrappingStrategyDefault(
   !     magnitude_suffix='_m',
   ! )
   subroutine iget_weight( &
      instance_index, &
      weight &
      )

      integer, intent(in) :: instance_index

      real(8), intent(out) :: weight
      ! Returning of weight

      type(Operator), pointer :: instance

      call manager_get_instance(instance_index, instance)

      weight = instance%weight

   end subroutine iget_weight

   subroutine iset_weight( &
      instance_index, &
      weight &
      )

      integer, intent(in) :: instance_index

      real(8), intent(in) :: weight
      ! Passing of weight

      type(Operator), pointer :: instance

      call manager_get_instance(instance_index, instance)

      instance%weight = weight

   end subroutine iset_weight

   ! Wrapped methods
   ! Wrapping vec_prod_sum
   ! Strategy: WrappingStrategyDefault(
   !     magnitude_suffix='_m',
   ! )
   subroutine i_calc_vec_prod_sum( &
      instance_index, &
      a, &
      b, &
      vec_prod_sum &
      )

      integer, intent(in) :: instance_index

      real(8), dimension(3), intent(in) :: a
      ! Passing of a

      real(8), dimension(3), intent(in) :: b
      ! Passing of b

      real(8), intent(out) :: vec_prod_sum
      ! Returning of vec_prod_sum

      type(Operator), pointer :: instance

      call manager_get_instance(instance_index, instance)

      vec_prod_sum = instance%calc_vec_prod_sum( &
                     a=a, &
                     b=b &
                     )

   end subroutine i_calc_vec_prod_sum

end module operations_w
