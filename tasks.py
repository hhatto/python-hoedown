from invoke import run, task


@task
def clean():
    run("python setup.py clean")


@task
def compile_cython():
    run("python setup.py compile_cython")


@task
def update_submodule():
    run("git submodule init")
    run("git submodule sync")
    run("git submodule update")


@task
def update():
    update_submodule()
    run("python setup.py update_vendor")


@task
def install():
    run("pip install --upgrade .")


@task
def tests():
    run("python tests/hoedown_test.py")


@task
def all():
    clean()
    update()
    compile_cython()
    install()
