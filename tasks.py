from invoke import run, task


@task
def compile_cython(j=False):
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
    update()
    compile_cython()
    run("pip install --upgrade .")
