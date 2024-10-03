"""
Python wrapper of the Fortran module ``operations_w``

``operations_w`` is itself a wrapper
around the Fortran module ``operations``.
"""
from __future__ import annotations

from typing import Any

import fgen_runtime.exceptions as fgr_excs
from attrs import define
from fgen_runtime.base import (
    INVALID_INSTANCE_INDEX,
    FinalizableWrapperBase,
    FinalizableWrapperBaseContext,
    check_initialised,
    execute_finalize_on_fail,
)
from fgen_runtime.units import verify_units

try:
    from fgen_example._lib import operations_w  # type: ignore
except (ModuleNotFoundError, ImportError) as exc:
    raise fgr_excs.CompiledExtensionNotFoundError("fgen_example._lib") from exc

_UNITS: dict[str, str] = {
    "weight": "dimensionless",
    "a": "dimensionless",
    "b": "dimensionless",
    "vec_prod_sum": "dimensionless",
}


@define
class Operator(FinalizableWrapperBase):
    """
    Wrapper around the Fortran :class:`Operator`

    An example of another derived type
    """

    @property
    def exposed_attributes(self) -> tuple[str, ...]:
        """
        Attributes exposed by this wrapper
        """
        return ("weight",)

    # Class methods
    @classmethod
    @verify_units(
        None,
        (
            None,
            _UNITS["weight"],
        ),
    )
    def from_build_args(
        cls,
        weight: float,
    ) -> Operator:
        """
        Initialise from build arguments

        This also creates a new connection to a Fortran object.
        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~OperatorContext`
        can be used to handle the finalisation using a context manager.

        Parameters
        ----------
        weight
            Weight to apply to operations

        Returns
        -------
            Built (i.e. linked to Fortran and initialised)
            :obj:`Operator`

        See Also
        --------
        :meth:`OperatorContext.from_build_args`
        """

        out = cls.from_new_connection()
        execute_finalize_on_fail(
            out,
            operations_w.instance_build,
            weight=weight,
        )

        return out

    @classmethod
    def from_new_connection(cls) -> Operator:
        """
        Initialise from a new connection

        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~OperatorContext`
        can be used to handle the finalisation using a context manager.

        Returns
        -------
            A new instance with a unique instance index

        Raises
        ------
        WrapperErrorUnknownCause
            If a new instance could not be allocated

            This could occur if too many instances are allocated at any one time
        """
        instance_index = operations_w.get_free_instance_number()
        if instance_index == INVALID_INSTANCE_INDEX:
            raise fgr_excs.WrapperErrorUnknownCause(  # noqa: TRY003
                f"Could not create instance of {cls.__name__}. "
            )

        return cls(instance_index)

    # Finalisation
    @check_initialised
    def finalize(self) -> None:
        """
        Close the connection with the Fortran module
        """
        operations_w.instance_finalize(self.instance_index)
        self._uninitialise_instance_index()

    # Attribute getters and setters
    @property
    @check_initialised
    @verify_units(
        _UNITS["weight"],
        (None,),
    )
    def weight(self) -> float:
        """
        Weight to apply to operations

        Returns
        -------
            Attribute value, retrieved from Fortran.

            The value is a copy of the derived type's data.
            Changes to this value will not be reflected
            in the underlying instance of the derived type.
            To make changes to the underlying instance, use the setter instead.
        """
        # Wrapping weight
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        weight: float = operations_w.iget_weight(
            instance_index=self.instance_index,
        )

        return weight

    # Wrapped methods
    @check_initialised
    @verify_units(
        _UNITS["vec_prod_sum"],
        (
            None,
            _UNITS["a"],
            _UNITS["b"],
        ),
    )
    def calc_vec_prod_sum(
        self,
        a: tuple[float, float, float],
        b: tuple[float, float, float],
    ) -> float:
        """
        Calculate vector product then sum then multiply by `self % weight`

        Parameters
        ----------
        a
            first vector

        b
            second vector

        Returns
        -------
            Result of doing vector product then sum then multiplying by `self % weight`
        """
        # Wrapping vec_prod_sum
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        vec_prod_sum: float = operations_w.i_calc_vec_prod_sum(
            instance_index=self.instance_index,
            a=a,
            b=b,
        )

        return vec_prod_sum


@define
class OperatorNoSetters(FinalizableWrapperBase):
    """
    Wrapper around the Fortran :class:`Operator`

    This wrapper has no setters so can be used for representing objects
    that have no connection to the underlying Fortran
    (i.e. changing their values/attributes
    will have no effect on the underlying Fortran).
    For example, derived type attribute values that are allocatable.

    An example of another derived type
    """

    @property
    def exposed_attributes(self) -> tuple[str, ...]:
        """
        Attributes exposed by this wrapper
        """
        return ("weight",)

    # Class methods
    @classmethod
    @verify_units(
        None,
        (
            None,
            _UNITS["weight"],
        ),
    )
    def from_build_args(
        cls,
        weight: float,
    ) -> OperatorNoSetters:
        """
        Initialise from build arguments

        This also creates a new connection to a Fortran object.
        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~OperatorNoSettersContext`
        can be used to handle the finalisation using a context manager.

        Parameters
        ----------
        weight
            Weight to apply to operations

        Returns
        -------
            Built (i.e. linked to Fortran and initialised)
            :obj:`OperatorNoSetters`

        See Also
        --------
        :meth:`OperatorNoSettersContext.from_build_args`
        """

        out = cls.from_new_connection()
        execute_finalize_on_fail(
            out,
            operations_w.instance_build,
            weight=weight,
        )

        return out

    @classmethod
    def from_new_connection(cls) -> OperatorNoSetters:
        """
        Initialise from a new connection

        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~OperatorNoSettersContext`
        can be used to handle the finalisation using a context manager.

        Returns
        -------
            A new instance with a unique instance index

        Raises
        ------
        WrapperErrorUnknownCause
            If a new instance could not be allocated

            This could occur if too many instances are allocated at any one time
        """
        instance_index = operations_w.get_free_instance_number()
        if instance_index == INVALID_INSTANCE_INDEX:
            raise fgr_excs.WrapperErrorUnknownCause(  # noqa: TRY003
                f"Could not create instance of {cls.__name__}. "
            )

        return cls(instance_index)

    # Finalisation
    @check_initialised
    def finalize(self) -> None:
        """
        Close the connection with the Fortran module
        """
        operations_w.instance_finalize(self.instance_index)
        self._uninitialise_instance_index()

    # Attribute getters
    @property
    @check_initialised
    @verify_units(
        _UNITS["weight"],
        (None,),
    )
    def weight(self) -> float:
        """
        Weight to apply to operations

        Returns
        -------
            Attribute value, retrieved from Fortran.

            The value is a copy of the derived type's data.
            Changes to this value will not be reflected
            in the underlying instance of the derived type.
            To make changes to the underlying instance, use the setter instead.
        """
        # Wrapping weight
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        weight: float = operations_w.iget_weight(
            instance_index=self.instance_index,
        )

        return weight

    # Wrapped methods
    @check_initialised
    @verify_units(
        _UNITS["vec_prod_sum"],
        (
            None,
            _UNITS["a"],
            _UNITS["b"],
        ),
    )
    def calc_vec_prod_sum(
        self,
        a: tuple[float, float, float],
        b: tuple[float, float, float],
    ) -> float:
        """
        Calculate vector product then sum then multiply by `self % weight`

        Parameters
        ----------
        a
            first vector

        b
            second vector

        Returns
        -------
            Result of doing vector product then sum then multiplying by `self % weight`
        """
        # Wrapping vec_prod_sum
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        vec_prod_sum: float = operations_w.i_calc_vec_prod_sum(
            instance_index=self.instance_index,
            a=a,
            b=b,
        )

        return vec_prod_sum


@define
class OperatorContext(FinalizableWrapperBaseContext):
    """
    Context manager for :class:`Operator`
    """

    @classmethod
    def from_build_args(
        cls,
        *args: Any,
        **kwargs: Any,
    ) -> OperatorContext:
        """
        Docstrings to be handled as part of #223
        """
        return cls(
            Operator.from_build_args(*args, **kwargs),
        )


@define
class OperatorNoSettersContext(FinalizableWrapperBaseContext):
    """
    Context manager for :class:`OperatorNoSetters`
    """

    @classmethod
    def from_build_args(
        cls,
        *args: Any,
        **kwargs: Any,
    ) -> OperatorNoSettersContext:
        """
        Docstrings to be handled as part of #223
        """
        return cls(
            OperatorNoSetters.from_build_args(*args, **kwargs),
        )
