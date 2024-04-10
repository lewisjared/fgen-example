"""
Python wrapper of the Fortran module ``derived_type_w``

``derived_type_w`` is itself a wrapper
around the Fortran module ``derived_type``.
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
from fgen_runtime.formatting import (
    to_html,
    to_pretty,
    to_str,
)
from fgen_runtime.units import verify_units

try:
    from fgen_example._lib import derived_type_w  # type: ignore
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

    @property
    def exposed_attributes(self) -> tuple[str, ...]:
        """
        Attributes exposed by this wrapper
        """
        return ("base",)

    def __str__(self) -> str:
        """
        String representation of self
        """
        return to_str(
            self,
            self.exposed_attributes,
        )

    def _repr_pretty_(self, p: Any, cycle: bool) -> None:
        """
        Pretty representation of self

        Used by IPython notebooks and other tools
        """
        to_pretty(
            self,
            self.exposed_attributes,
            p=p,
            cycle=cycle,
        )

    def _repr_html_(self) -> str:
        """
        html representation of self

        Used by IPython notebooks and other tools
        """
        return to_html(
            self,
            self.exposed_attributes,
        )

    # Class methods
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
        Initialise from build arguments

        This also creates a new connection to a Fortran object.
        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~DerivedTypeContext`
        can be used to handle the finalisation using a context manager.

        Parameters
        ----------
        base
            Base value

        Returns
        -------
            Built (i.e. linked to Fortran and initialised)
            :obj:`DerivedType`

        See Also
        --------
        :meth:`DerivedTypeContext.from_build_args`
        """
        out = cls.from_new_connection()
        execute_finalize_on_fail(
            out,
            derived_type_w.instance_build,
            base=base,
        )

        return out

    @classmethod
    def from_new_connection(cls) -> DerivedType:
        """
        Initialise from a new connection

        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~DerivedTypeContext`
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
        instance_index = derived_type_w.get_free_instance_number()
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
        derived_type_w.instance_finalize(self.instance_index)
        self._uninitialise_instance_index()

    # Attribute getters and setters
    @property
    @check_initialised
    @verify_units(
        _UNITS["base"],
        (None,),
    )
    def base(self) -> float:
        """
        Base value

        Returns
        -------
            Attribute value, retrieved from Fortran.

            The value is a copy of the derived type's data.
            Changes to this value will not be reflected
            in the underlying instance of the derived type.
            To make changes to the underlying instance, use the setter instead.
        """
        # Wrapping base
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        base: float = derived_type_w.iget_base(
            self.instance_index,
        )

        return base

    # Wrapped methods
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

        Parameters
        ----------
        other
            Quantity to add

        Returns
        -------
            Sum of `self.base` and `other`
        """
        # Wrapping output
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        output: float = derived_type_w.i_add(
            self.instance_index,
            other=other,
        )

        return output

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

        Returns
        -------
            Double `self.base`
        """
        # Wrapping output
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        output: float = derived_type_w.i_double(
            self.instance_index,
        )

        return output


@define
class DerivedTypeNoSetters(FinalizableWrapperBase):
    """
    Wrapper around the Fortran :class:`DerivedType`

    This wrapper has no setters so can be used for representing objects
    that have no connection to the underlying Fortran
    (i.e. changing their values/attributes
    will have no effect on the underlying Fortran).
    For example, derived type attribute values that are allocatable.

    An example of a derived type
    """

    @property
    def exposed_attributes(self) -> tuple[str, ...]:
        """
        Attributes exposed by this wrapper
        """
        return ("base",)

    def __str__(self) -> str:
        """
        String representation of self
        """
        return to_str(
            self,
            self.exposed_attributes,
        )

    def _repr_pretty_(self, p: Any, cycle: bool) -> None:
        """
        Pretty representation of self

        Used by IPython notebooks and other tools
        """
        to_pretty(
            self,
            self.exposed_attributes,
            p=p,
            cycle=cycle,
        )

    def _repr_html_(self) -> str:
        """
        html representation of self

        Used by IPython notebooks and other tools
        """
        return to_html(
            self,
            self.exposed_attributes,
        )

    # Class methods
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
    ) -> DerivedTypeNoSetters:
        """
        Initialise from build arguments

        This also creates a new connection to a Fortran object.
        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~DerivedTypeNoSettersContext`
        can be used to handle the finalisation using a context manager.

        Parameters
        ----------
        base
            Base value

        Returns
        -------
            Built (i.e. linked to Fortran and initialised)
            :obj:`DerivedTypeNoSetters`

        See Also
        --------
        :meth:`DerivedTypeNoSettersContext.from_build_args`
        """
        out = cls.from_new_connection()
        execute_finalize_on_fail(
            out,
            derived_type_w.instance_build,
            base=base,
        )

        return out

    @classmethod
    def from_new_connection(cls) -> DerivedTypeNoSetters:
        """
        Initialise from a new connection

        The user is responsible for releasing this connection
        using :attr:`~finalize` when it is no longer needed.
        Alternatively a :obj:`~DerivedTypeNoSettersContext`
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
        instance_index = derived_type_w.get_free_instance_number()
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
        derived_type_w.instance_finalize(self.instance_index)
        self._uninitialise_instance_index()

    # Attribute getters
    @property
    @check_initialised
    @verify_units(
        _UNITS["base"],
        (None,),
    )
    def base(self) -> float:
        """
        Base value

        Returns
        -------
            Attribute value, retrieved from Fortran.

            The value is a copy of the derived type's data.
            Changes to this value will not be reflected
            in the underlying instance of the derived type.
            To make changes to the underlying instance, use the setter instead.
        """
        # Wrapping base
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        base: float = derived_type_w.iget_base(
            self.instance_index,
        )

        return base

    # Wrapped methods
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

        Parameters
        ----------
        other
            Quantity to add

        Returns
        -------
            Sum of `self.base` and `other`
        """
        # Wrapping output
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        output: float = derived_type_w.i_add(
            self.instance_index,
            other=other,
        )

        return output

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

        Returns
        -------
            Double `self.base`
        """
        # Wrapping output
        # Strategy: WrappingStrategyDefault(
        #     magnitude_suffix='_m',
        # )
        output: float = derived_type_w.i_double(
            self.instance_index,
        )

        return output


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


@define
class DerivedTypeNoSettersContext(FinalizableWrapperBaseContext):
    """
    Context manager for :class:`DerivedTypeNoSetters`
    """

    @classmethod
    def from_build_args(
        cls,
        *args: Any,
        **kwargs: Any,
    ) -> DerivedTypeNoSettersContext:
        """
        Docstrings to be handled as part of #223
        """
        return cls(
            DerivedTypeNoSetters.from_build_args(*args, **kwargs),
        )
