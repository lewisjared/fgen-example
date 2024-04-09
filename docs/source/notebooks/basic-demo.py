# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.14.5
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %% [markdown]
# # Basic demo
#
# This notebook gives a basic demonstration of how to use Fgen Example.

# %%
import openscm_units
import pint

# %% [markdown]
# You must set the application registry before importing other packages ensure
# the unit registry is set correctly. If you do this step after importing a
# library that uses `fgen_runtime.verify_units`, it is too late because
# `fgen_runtime.verify_units` will have already been called and will have
# already set the registry to be used when entering and exiting wrapped
# methods. This is an issue with pint's/`fgen_runtime.verify_unit`'s way of
# doing the wrapping which we haven't tried to tackle in a neater way yet.

# %%
UR = openscm_units.unit_registry
pint.set_application_registry(UR)

# %%
import fgen_example
from fgen_example.derived_type import DerivedType

# %%
print(f"You are using fgen_example version {fgen_example.__version__}")

# %% [markdown]
# The auto-generated Python wrappers give Python access to derived types defined in Fortran.

# %%
dt = DerivedType.from_build_args(base=UR.Quantity(2, "m"))
dt

# %%
dt.base

# %%
dt.add(UR.Quantity(3, "cm"))
