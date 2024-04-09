! TODO: add fgen support for plain functions rather than derived types
!       (tracking here https://gitlab.com/magicc/fgen/-/issues/13)
module operations
   use fgen_base_finalizable, only: BaseFinalizable

   implicit none
   private

   public :: Operator

   type, extends(BaseFinalizable) :: Operator

      real(8) :: weight

   contains

      private

      procedure, public :: build, finalize, calc_vec_prod_sum

   end type Operator

contains

   subroutine build(self, weight)

      class(Operator), intent(inout) :: self

      real(8), intent(in) :: weight

      self%weight = weight

   end subroutine build

   function calc_vec_prod_sum(self, a, b) result(vec_prod_sum)

      class(Operator), intent(inout) :: self
      real(8), dimension(3) :: a, b

      real(8) :: vec_prod_sum

      integer :: i

      vec_prod_sum = 0

      do i = 1, size(a)

         vec_prod_sum = vec_prod_sum + (a(i)*b(i))

      end do

      vec_prod_sum = self%weight*vec_prod_sum

   end function calc_vec_prod_sum

   subroutine finalize(self)

      class(Operator), intent(inout) :: self

   end subroutine finalize

end module operations
