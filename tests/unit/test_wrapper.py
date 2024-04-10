"""
Test wrapper

These tests are simply here to demonstrate how the tests can be set up and how
the wrapping module can be used. You will likely significantly modify or even
delete this file early in the project.
"""
import pint
import pint.testing

from fgen_example.derived_type import DerivedType
from fgen_example.operations import OperatorContext

Q = pint.get_application_registry().Quantity


def test_add():
    dt = DerivedType.from_build_args(base=Q(2, "m"))
    pint.testing.assert_allclose(dt.add(Q(3, "m")), Q(5, "m"))
    pint.testing.assert_allclose(dt.add(Q(3, "mm")), Q(2.003, "m"))


def test_double():
    dt = DerivedType.from_build_args(base=Q(2, "m"))
    pint.testing.assert_allclose(dt.double(), Q(4, "m"))


def test_calc_vec_prod_sum():
    with OperatorContext.from_build_args(weight=Q(2, "1")) as operator:
        pint.testing.assert_allclose(
            operator.calc_vec_prod_sum(
                Q([1, 2, 3], "1"),
                Q([3, 2, 1], "1"),
            ),
            Q(20, "1"),
        )
