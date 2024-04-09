"""
Test wrapper

These tests are simply here to demonstrate how the tests can be set up and how
the wrapping module can be used. You will likely significantly modify or even
delete this file early in the project.
"""
import openscm_units
import pint
import pint.testing

from fgen_example.derived_type import DerivedType
from fgen_example.operations import OperatorContext

UR = openscm_units.unit_registry
pint.set_application_registry(UR)


def test_add():
    dt = DerivedType.from_build_args(base=UR.Quantity(2, "m"))
    pint.testing.assert_allclose(dt.add(UR.Quantity(3, "m")), UR.Quantity(5, "m"))
    pint.testing.assert_allclose(dt.add(UR.Quantity(3, "mm")), UR.Quantity(2.003, "m"))


def test_double():
    dt = DerivedType.from_build_args(base=UR.Quantity(2, "m"))
    pint.testing.assert_allclose(dt.double(), UR.Quantity(4, "m"))


def test_calc_vec_prod_sum():
    with OperatorContext.from_build_args(weight=UR.Quantity(2, "1")) as operator:
        pint.testing.assert_allclose(
            operator.calc_vec_prod_sum(
                UR.Quantity([1, 2, 3], "1"),
                UR.Quantity([3, 2, 1], "1"),
            ),
            UR.Quantity(20, "1"),
        )
