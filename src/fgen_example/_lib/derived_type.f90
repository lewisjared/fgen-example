! A module that exposes a derived type via fgen.

module derived_type
   use fgen_base_finalizable, only: BaseFinalizable

   implicit none
   private

   public :: DerivedType

   type, extends(BaseFinalizable) :: DerivedType

      real(8) :: base

   contains

      private

      procedure, public :: build, finalize, add, double

   end type DerivedType

contains

   subroutine build(self, base)

      class(DerivedType), intent(inout) :: self

      real(8), intent(in) :: base

      self%base = base

   end subroutine build

   function add(self, other) result(output)

      class(DerivedType), intent(inout) :: self

      real(8) :: other

      real(8) :: output

      output = self%base + other

   end function add

   function double(self) result(output)

      class(DerivedType), intent(inout) :: self

      real(8) :: output

      output = self%base*2.0

   end function double

   subroutine finalize(self)

      class(DerivedType), intent(inout) :: self

   end subroutine finalize

end module derived_type
