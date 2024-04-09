!
! Manager for the lifecycle of the Operator calculator
!

module mod_operations_manager
   use operations, only: &
      Operator
   use fgen_utils, only: &
      finalize_derived_type_instance_number, &
      get_derived_type_free_instance_number

   implicit none
   private

   integer, parameter :: N_MODELS = 2048

   type(Operator), target, dimension(N_MODELS) :: instance_array
   logical, dimension(N_MODELS) :: instance_available = .true.

   public :: get_free_instance_number, &
             get_instance, &
             instance_finalize, &
             check_index_claimed

contains

   function get_free_instance_number() result(model_index)

      integer :: model_index

      call get_derived_type_free_instance_number( &
         model_index, &
         N_MODELS, &
         instance_available, &
         instance_array &
         )

   end function get_free_instance_number

   subroutine get_instance(model_index, instance)
      ! Get an instance for a given model index
      !
      ! This will stop execution if the instance has not already been initialised

      integer, intent(in) :: model_index
      type(Operator), pointer, intent(inout) :: instance

      call check_index_claimed(model_index)
      instance => instance_array(model_index)

   end subroutine get_instance

   subroutine instance_finalize(model_index)

      integer, intent(in) :: model_index

      call check_index_claimed(model_index)
      call finalize_derived_type_instance_number( &
         model_index, &
         N_MODELS, &
         instance_available, &
         instance_array &
         )

   end subroutine instance_finalize

   !
   ! Private routines
   !

   subroutine check_index_claimed(model_index)

      integer, intent(in) :: model_index

      if (instance_available(model_index) &
          .or. model_index < 1 &
          .or. instance_array(model_index)%model_index < 1) then
         ! TODO: return error code to python
         stop
      end if

   end subroutine check_index_claimed

end module mod_operations_manager
