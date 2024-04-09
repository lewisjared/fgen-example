module two_layer_model

   use fgen_base_finalizable, only: BaseFinalizable

   implicit none
   private

   public :: TwoLayerModel

   type, extends(BaseFinalizable) :: TwoLayerModel

      real(8) :: lambda0
      real(8) :: a
      real(8) :: efficacy
      real(8) :: eta
      real(8) :: heat_capacity_surface
      real(8) :: heat_capacity_deep

   contains

      private

      procedure, public :: build, finalize, calculate

   end type TwoLayerModel

contains

   subroutine build( &
      self, &
      lambda0, &
      a, &
      efficacy, &
      eta, &
      heat_capacity_surface, &
      heat_capacity_deep &
      )

      ! TODO: Making this intent(out) rather than intent(inout) was really bad
      ! and hard to debug. Not sure how to help people with this though as it
      ! isn't easy to detect...
      class(TwoLayerModel), intent(inout) :: self

      real(8), intent(in) :: lambda0
      real(8), intent(in) :: a
      real(8), intent(in) :: efficacy
      real(8), intent(in) :: eta
      real(8), intent(in) :: heat_capacity_surface
      real(8), intent(in) :: heat_capacity_deep

      self%lambda0 = lambda0
      self%a = a
      self%efficacy = efficacy
      self%eta = eta
      self%heat_capacity_surface = heat_capacity_surface
      self%heat_capacity_deep = heat_capacity_deep

   end subroutine build

   function calculate( &
      self, &
      erf, &
      temperature_surface, &
      temperature_deep &
      ) result(dy_dt)

      class(TwoLayerModel), intent(inout) :: self

      real(8), intent(in) :: erf
      real(8), intent(in) :: temperature_surface
      real(8), intent(in) :: temperature_deep

      real(8), dimension(3) :: dy_dt

      real(8) :: temperature_difference
      real(8) :: lambda_eff
      real(8) :: heat_exchange_surface
      real(8) :: heat_exchange_deep
      real(8) :: dtemperature_surface_dt
      real(8) :: dtemperature_deep_dt

      temperature_difference = temperature_surface - temperature_deep

      lambda_eff = self%lambda0 - self%a*temperature_surface
      heat_exchange_surface = self%efficacy*self%eta*temperature_difference
      dtemperature_surface_dt = ( &
                                erf - lambda_eff*temperature_surface - heat_exchange_surface &
                                )/self%heat_capacity_surface

      heat_exchange_deep = self%eta*temperature_difference
      dtemperature_deep_dt = heat_exchange_deep/self%heat_capacity_deep

      dy_dt(1) = dtemperature_surface_dt
      dy_dt(2) = dtemperature_deep_dt
      dy_dt(3) = ( &
                 self%heat_capacity_surface*dtemperature_surface_dt &
                 + self%heat_capacity_deep*dtemperature_deep_dt &
                 )

   end function calculate

   subroutine finalize(self)

      class(TwoLayerModel), intent(inout) :: self

   end subroutine finalize

end module two_layer_model
