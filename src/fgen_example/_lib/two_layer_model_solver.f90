module tlm_solver
   ! Two-layer model solver to use in integration testing.

   use fgen_base_finalizable, only: BaseFinalizable
   use fgen_base_stepper, only: BaseStepper
   use fgen_euler_forward, only: EulerForwardStepper
   use fgen_rk, only: RK4Stepper
   use fgen_1d_interpolation_base, only: BaseInterpolation1D
   use fgen_1d_linear_spline, only: Interp1DLinearSpline
   use fgen_1d_next, only: Interp1DNext
   use fgen_1d_handling_options, only: LinearSpline, Next, NotSpecified, Previous
   use fgen_1d_previous, only: Interp1DPrevious
   use fgen_solve_ivp, only: IVPSolvingResult, solve_ivp
   use fgen_time, only: TimeAxis
   use fgen_timeseries, only: Timeseries
   use fgen_timeseries_manager, only: get_timeseries_free_instance_number => get_free_instance_number
   use fgen_timeseries_manager, only: timeseries_manager_get_instance => get_instance
   use fgen_values_bounded, only: ValuesBounded

   use two_layer_model, only: TwoLayerModel

   implicit none
   private

   public :: TwoLayerModelSolver

   type, extends(BaseFinalizable) :: TwoLayerModelSolver

      ! Hmmm, interesting question whether to encapsulate here or not.
      ! My instinct is yes, so
      ! TODO: change to
      ! type(TwoLayerModel), allocatable :: two_layer_model
      type(TwoLayerModel), pointer :: two_layer_model
      real(kind=8) :: t_next
      real(kind=8) :: temperature_surface_next
      real(kind=8) :: temperature_deep_next
      real(kind=8) :: cumulative_heat_uptake_next

   contains

      private

      procedure, public :: build, finalize, solve_euler_forward, solve_rk4
      procedure, private :: solve

   end type TwoLayerModelSolver

contains

   subroutine build( &
      self, &
      two_layer_model, &
      t_next, &
      temperature_surface_next, &
      temperature_deep_next, &
      cumulative_heat_uptake_next &
      )

      class(TwoLayerModelSolver), intent(inout) :: self

      type(TwoLayerModel), pointer, intent(in) :: two_layer_model
      real(kind=8), intent(in) :: t_next
      real(kind=8), intent(in) :: temperature_surface_next
      real(kind=8), intent(in) :: temperature_deep_next
      real(kind=8), intent(in) :: cumulative_heat_uptake_next

      self%two_layer_model => two_layer_model
      self%t_next = t_next
      self%temperature_surface_next = temperature_surface_next
      self%temperature_deep_next = temperature_deep_next
      self%cumulative_heat_uptake_next = cumulative_heat_uptake_next

   end subroutine build

   ! Need separate functions for each input type so our wrappers can wrap easily.
   ! Then don't expose solve i.e. the general function.
   function solve_euler_forward( &
      self, &
      erf, &
      time_eval, &
      stepper &
      ) result(res)

      class(TwoLayerModelSolver), intent(inout) :: self

      type(Timeseries), intent(in) :: erf
      type(TimeAxis), intent(in) :: time_eval

      type(EulerForwardStepper), intent(inout) :: stepper

      ! TODO: try and use the below instead once our wrappers can handle it
      ! type(Timeseries), dimension(3), allocatable :: res
      ! type(Timeseries), dimension(3) :: res
      integer, dimension(3) :: res

      res = self%solve( &
            erf=erf, &
            time_eval=time_eval, &
            stepper=stepper &
            )

   end function solve_euler_forward

   function solve_rk4( &
      self, &
      erf, &
      time_eval, &
      stepper &
      ) result(res)

      class(TwoLayerModelSolver), intent(inout) :: self

      type(Timeseries), intent(in) :: erf
      type(TimeAxis), intent(in) :: time_eval

      type(RK4Stepper), intent(inout) :: stepper

      ! TODO: try and use the below instead once our wrappers can handle it
      ! type(Timeseries), dimension(3), allocatable :: res
      ! type(Timeseries), dimension(3) :: res
      integer, dimension(3) :: res

      res = self%solve( &
            erf=erf, &
            time_eval=time_eval, &
            stepper=stepper &
            )

   end function solve_rk4

   function solve( &
      self, &
      erf, &
      time_eval, &
      stepper &
      ) result(res)

      class(TwoLayerModelSolver), intent(inout) :: self

      type(Timeseries), intent(in) :: erf
      type(TimeAxis), intent(in) :: time_eval

      class(BaseStepper), intent(inout) :: stepper

      ! TODO: try and use the below instead once our wrappers can handle it
      ! type(Timeseries), dimension(3), allocatable :: res
      ! type(Timeseries), dimension(3) :: res
      integer, dimension(3) :: res

      integer :: temperature_surface_index
      type(TimeAxis) :: time_out
      type(ValuesBounded) :: temperature_surface_values
      ! If we change our manager to hold an allocatable array,
      ! rather than an array of pointers,
      ! I think we can remove the need for the pointer attributes
      ! for the Timeseries objects below.
      type(Timeseries), pointer :: temperature_surface
      integer :: temperature_deep_index
      type(ValuesBounded) :: temperature_deep_values
      type(Timeseries), pointer :: temperature_deep
      integer :: cumulative_heat_uptake_index
      type(ValuesBounded) :: cumulative_heat_uptake_values
      type(Timeseries), pointer :: cumulative_heat_uptake

      type(IVPSolvingResult) :: result

      call solve_ivp( &
         stepper=stepper, &
         integrand=two_layer_model_integrand, &
         t0=self%t_next, &
         y0=(/ &
         self%temperature_surface_next, &
         self%temperature_deep_next, &
         self%cumulative_heat_uptake_next &
         /), &
         t_eval=time_eval, &
         result=result &
         )

      ! At some point we'll get sick of re-writing this
      ! and abstract out some more general method I suspect.
      ! I think all you need is the names and units of the things
      time_out = TimeAxis( &
                 values=result%t, &
                 value_last_bound=stepper%t, &
                 units=time_eval%units &
                 )

      temperature_surface_values = ValuesBounded( &
                                   values=result%y(:, 1), &
                                   value_last_bound=stepper%y(1), &
                                   units="K / yr "//time_eval%units &
                                   )

      temperature_surface_index = get_timeseries_free_instance_number()
      call timeseries_manager_get_instance(temperature_surface_index, temperature_surface)
      temperature_surface = Timeseries( &
                            name="temperature_surface", &
                            values=temperature_surface_values, &
                            time=time_out, &
                            spline=LinearSpline &
                            )
      temperature_surface%instance_index = temperature_surface_index

      temperature_deep_values = ValuesBounded( &
                                values=result%y(:, 2), &
                                value_last_bound=stepper%y(2), &
                                units="K / yr "//time_eval%units &
                                )

      temperature_deep_index = get_timeseries_free_instance_number()
      call timeseries_manager_get_instance(temperature_deep_index, temperature_deep)
      temperature_deep = Timeseries( &
                         name="temperature_deep", &
                         values=temperature_deep_values, &
                         time=time_out, &
                         spline=LinearSpline &
                         )
      temperature_deep%instance_index = temperature_deep_index

      cumulative_heat_uptake_values = ValuesBounded( &
                                      values=result%y(:, 3), &
                                      value_last_bound=stepper%y(3), &
                                      units="W / m^2 yr / yr "//time_eval%units &
                                      )

      cumulative_heat_uptake_index = get_timeseries_free_instance_number()
      call timeseries_manager_get_instance(cumulative_heat_uptake_index, cumulative_heat_uptake)
      cumulative_heat_uptake = Timeseries( &
                               name="cumulative_heat_uptake", &
                               values=cumulative_heat_uptake_values, &
                               time=time_out, &
                               spline=LinearSpline &
                               )
      cumulative_heat_uptake%instance_index = cumulative_heat_uptake_index

      res(1) = temperature_surface_index
      res(2) = temperature_deep_index
      res(3) = cumulative_heat_uptake_index
      ! TODO: switch back to this once our wrappers
      ! can handle returning arrays of derived types.
      ! res = [ &
      !       temperature_surface, &
      !       temperature_deep, &
      !       cumulative_heat_uptake &
      !       ]

      ! This will probably have to be implemented by every solver, so be it.
      ! (Might be some way to abstract, but might be more trouble than it's worth).
      self%t_next = stepper%t
      self%temperature_surface_next = stepper%y(1)
      self%temperature_deep_next = stepper%y(2)
      self%cumulative_heat_uptake_next = stepper%y(3)

   contains

      function two_layer_model_integrand(t, y) result(dy_dt)

         real(kind=8), intent(in) :: t

         real(kind=8), dimension(:), intent(in) :: y

         real(kind=8), dimension(:), allocatable :: dy_dt

         dy_dt = self%two_layer_model%calculate( &
                 erf=erf%interpolate_single(t), &
                 temperature_surface=y(1), &
                 temperature_deep=y(2) &
                 ! y(3) not used in calculate
                 )

      end function two_layer_model_integrand

   end function solve

   subroutine finalize(self)

      class(TwoLayerModelSolver), intent(inout) :: self

   end subroutine finalize

end module tlm_solver
