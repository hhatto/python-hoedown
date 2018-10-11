from invoke import task


@task
def clean(c):
    c.run("python setup.py clean")


@task
def compile_cython(c):
    c.run("python setup.py compile_cython")


@task
def update_submodule(c):
    c.run("git submodule init")
    c.run("git submodule sync")
    c.run("git submodule update")


@task
def update(c):
    update_submodule(c)
    c.run("python setup.py update_vendor")


@task
def install(c):
    c.run("pip install --upgrade .")


@task
def tests(c):
    c.run("python tests/hoedown_test.py")


@task
def all(c):
    clean(c)
    update(c)
    compile_cython(c)
    install(c)
