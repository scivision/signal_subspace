import numpy as np
import pytest


@pytest.fixture
def fake_sig():
    return np.random.randn(4096).astype(np.complex128)
