"""
Python wrapper of Fortran module derived_type
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
    from fgen_example._lib import w_derived_type  # type: ignore
except (ModuleNotFoundError, ImportError) as exc:
    raise fgr_excs.CompiledExtensionNotFoundError("fgen_example._lib") from exc

_UNITS: dict[str, str] = {
    "base": "m",
    "other": "m",
    "output": "m",
}


@define
class DerivedType(FinalizableWrapperBase):
    """
    Wrapper around the Fortran :class:`DerivedType`

    An example of a derived type
    """

    def __str__(self) -> str:
        if self.model_index == INVALID_MODEL_INDEX:
            return f"Uninitialised {self!r}"

        props = [
            "base",
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
    def from_new_connection(cls) -> DerivedType:
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
        model_index = w_derived_type.get_free_instance()
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
        w_derived_type.instance_finalize(self.model_index)
        self._uninitialise_model_index()

    @classmethod
    @verify_units(
        None,
        (
            None,
            _UNITS["base"],
        ),
    )
    def from_build_args(
        cls,
        base: float,
    ) -> DerivedType:
        """
        Build a new DerivedType

        Creates a new connection to a Fortran object. The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed. Alternatively a
        :class:`DerivedTypeContext`
        can be used to handle the finalization using a context manager.

        See Also
        --------
        :meth:`DerivedTypeContext.from_build_args`
        """
        out = cls.from_new_connection()

        execute_finalize_on_fail(
            out,
            w_derived_type.instance_build,
            base=base,
        )

        return out

    @check_initialised
    @verify_units(
        _UNITS["output"],
        (
            None,
            _UNITS["other"],
        ),
    )
    def add(
        self,
        other: float,
    ) -> float:
        """
        Add another value to `self.base`
        """
        out: float = w_derived_type.i_add(
            self.model_index,
            other,
        )

        return out

    @check_initialised
    @verify_units(
        _UNITS["output"],
        (None,),
    )
    def double(
        self,
    ) -> float:
        """
        Double `self.base`
        """
        out: float = w_derived_type.i_double(
            self.model_index,
        )

        return out

    @property
    @check_initialised
    @verify_units(
        _UNITS["base"],
        (None,),
    )
    def base(self) -> float:
        """
        Base value
        """
        # fmt: off
        out: float \
            = w_derived_type.ig_base(self.model_index)
        # fmt: on

        return out


@define
class DerivedTypeContext(FinalizableWrapperBaseContext):
    """
    Context manager for :class:`DerivedType`
    """

    @classmethod
    def from_build_args(
        cls,
        *args: Any,
        **kwargs: Any,
    ) -> DerivedTypeContext:
        """
        Docstrings to be handled as part of #223
        """
        return cls(
            DerivedType.from_build_args(*args, **kwargs),
        )
