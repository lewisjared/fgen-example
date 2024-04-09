!
! Wrapper for mod_operations_manager
! Exposes the Operator calculator
!
module w_operations
   use iso_c_binding, only: c_loc, c_ptr
   use mod_operations_manager, only: &
      manager_get_free_instance => get_free_instance_number, &
      manager_instance_finalize => instance_finalize, &
      manager_get_instance => get_instance, &
      check_index_claimed

   use operations, only: &
      Operator

   implicit none
   private

   ! TODO: handle cases where more complicated wrappers are needed
   public :: get_free_instance, &
             instance_build, &
             instance_finalize

   ! Getters
   public :: ig_weight
   ! Calculator methods
   public :: i_calc_vec_prod_sum
contains

   function get_free_instance() result(model_index)

      integer :: model_index

      model_index = manager_get_free_instance()

   end function get_free_instance

   subroutine instance_finalize(model_index)

      integer, intent(in) :: model_index

      call manager_instance_finalize(model_index)

   end subroutine instance_finalize

   !
   ! Build a new instance
   !
   subroutine instance_build( &
      model_index, &
      weight &
      )

      integer, intent(in) :: model_index
      real(8), intent(in) :: weight
      type(Operator), pointer :: instance

      call manager_get_instance(model_index, instance)

      call instance%build( &
         weight &
         )

   end subroutine instance_build

   !
   ! Calculator accessors
   !

   function ig_weight(model_index) result(weight)

      integer, intent(in) :: model_index
      real(8) :: weight

      type(Operator), pointer :: instance

      call manager_get_instance(model_index, instance)

      weight = instance%weight

   end function ig_weight

   !
   ! Calculator methods
   !

   function i_calc_vec_prod_sum( &
      model_index, &
      a, &
      b &
      ) result(vec_prod_sum)

      ! Should work out consistent approach to whether we use intent or not...
      integer :: model_index
      real(8), dimension(3) :: a
      real(8), dimension(3) :: b
      real(8) :: vec_prod_sum

      type(Operator), pointer :: instance

      call manager_get_instance(model_index, instance)

      !&<
      vec_prod_sum = instance % calc_vec_prod_sum( &
          a, &
          b &
          )
      !&>
   end function i_calc_vec_prod_sum

end module w_operations
