import pytest

def test_bash_true_results_in_0(host):
    output = host.run('bash -c "true"')
    assert output.rc == 0

def test_bash_true_results_in_0(host):
    output = host.run('bash -c "false"')
    assert output.rc > 0

def test_php_pcntl_is_enabled(host):
    output = host.run('php -r "exit(function_exists(\'pcntl_signal\') ? 0 : 255);"')
    assert output.rc == 0

    output = host.run('php -r "exit(function_exists(\'pcntl_async_signals\') ? 0 : 255);"')
    assert output.rc == 0
