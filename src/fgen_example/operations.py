"""
Python wrapper of Fortran module operations
"""
from __future__ import annotations

from typing import Any

import fgen_runtime.exceptions as fgr_excs
from attrs import define
from fgen_runtime.base import (
    INVALID_MODEL_INDEX,
    FinalizableWrapperBase,
    FinalizableWrapperBaseContext,
    check_initialised,
    execute_finalize_on_fail,
)
from fgen_runtime.exceptions import PointerArrayConversionError
from fgen_runtime.units import verify_units

try:
    from fgen_example._lib import w_operations  # type: ignore
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

    def __str__(self) -> str:
        if self.model_index == INVALID_MODEL_INDEX:
            return f"Uninitialised {self!r}"

        props = [
            "weight",
        ]
        prop_vals = []
        for p in props:
            try:
                prop_vals.append(f"{p}={getattr(self, p)}")
            except PointerArrayConversionError:
                prop_vals.append(
                    f"{p} could not be retrieved from its pointer, perhaps it is unset?",
                )

        base = repr(self)
        out = f"{base[:-1]}, {', '.join(prop_vals)})"

        return out

    @classmethod
    def from_new_connection(cls) -> Operator:
        """
        Allocate a new calculator instance

        Returns
        -------
            A new instance with a unique model index

        Raises
        ------
        WrapperErrorUnknownCause
            If a new instance could not be allocated

            This could occur if too many models are allocated at any one time
        """
        model_index = w_operations.get_free_instance()
        if model_index == INVALID_MODEL_INDEX:
            raise fgr_excs.WrapperErrorUnknownCause(  # noqa: TRY003
                f"Could not create instance of {cls.__name__}. "
            )

        return cls(model_index)

    @check_initialised
    def finalize(self) -> None:
        """
        Close the connection with the Fortran module
        """
        w_operations.instance_finalize(self.model_index)
        self._uninitialise_model_index()

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
        Build a new Operator

        Creates a new connection to a Fortran object. The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed. Alternatively a
        :class:`OperatorContext`
        can be used to handle the finalization using a context manager.

        See Also
        --------
        :meth:`OperatorContext.from_build_args`
        """
        out = cls.from_new_connection()

        execute_finalize_on_fail(
            out,
            w_operations.instance_build,
            weight=weight,
        )

        return out

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
        """
        out: float = w_operations.i_calc_vec_prod_sum(
            self.model_index,
            a,
            b,
        )

        return out

    @property
    @check_initialised
    @verify_units(
        _UNITS["weight"],
        (None,),
    )
    def weight(self) -> float:
        """
        Weight to apply to operations
        """
        # fmt: off
        out: float \
            = w_operations.ig_weight(self.model_index)
        # fmt: on

        return out


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
