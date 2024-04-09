!
! Wrapper for mod_derived_type_manager
! Exposes the DerivedType calculator
!
module w_derived_type
   use iso_c_binding, only: c_loc, c_ptr
   use mod_derived_type_manager, only: &
      manager_get_free_instance => get_free_instance_number, &
      manager_instance_finalize => instance_finalize, &
      manager_get_instance => get_instance, &
      check_index_claimed

   use derived_type, only: &
      DerivedType

   implicit none
   private

   ! TODO: handle cases where more complicated wrappers are needed
   public :: get_free_instance, &
             instance_build, &
             instance_finalize

   ! Getters
   public :: ig_base
   ! Calculator methods
   public :: i_add
   public :: i_double
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
      base &
      )

      integer, intent(in) :: model_index
      real(8), intent(in) :: base
      type(DerivedType), pointer :: instance

      call manager_get_instance(model_index, instance)

      call instance%build( &
         base &
         )

   end subroutine instance_build

   !
   ! Calculator accessors
   !

   function ig_base(model_index) result(base)

      integer, intent(in) :: model_index
      real(8) :: base

      type(DerivedType), pointer :: instance

      call manager_get_instance(model_index, instance)

      base = instance%base

   end function ig_base

   !
   ! Calculator methods
   !

   function i_add( &
      model_index, &
      other &
      ) result(output)

      ! Should work out consistent approach to whether we use intent or not...
      integer :: model_index
      real(8) :: other
      real(8) :: output

      type(DerivedType), pointer :: instance

      call manager_get_instance(model_index, instance)

      !&<
      output = instance % add( &
          other &
          )
      !&>
   end function i_add

   function i_double( &
      model_index &
      ) result(output)

      ! Should work out consistent approach to whether we use intent or not...
      integer :: model_index
      real(8) :: output

      type(DerivedType), pointer :: instance

      call manager_get_instance(model_index, instance)

      !&<
      output = instance % double( &
          )
      !&>
   end function i_double

end module w_derived_type
