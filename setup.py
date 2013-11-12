import os
import glob
import shutil
import os.path

try:
    from setuptools import setup, Extension, Command
except ImportError:
    from distutils.core import setup, Extension, Command


exec(open('hoedownpy/_version.py').read())
dirname = os.path.dirname(os.path.abspath(__file__))


class BaseCommand(Command):
    user_options = []
    def initialize_options(self):
        pass
    def finalize_options(self):
        pass


class CleanCommand(BaseCommand):
    description = 'cleanup directories created by packaging and build processes'
    def run(self):
        for path in ['build', 'dist', 'hoedownpy.egg-info', 'docs/_build', 'temp']:
            if os.path.exists(path):
                path = os.path.join(dirname, path)
                print('removing %s' % path)
                shutil.rmtree(path)


class CythonCommand(BaseCommand):
    description = 'compile Cython files(s) into C file(s)'
    def run(self):
        try:
            from Cython.Compiler.Main import compile
            for f in ("hoedown.pyx", "wrapper.pxd"):
                path = os.path.join(dirname, 'hoedownpy', f)
                print('compiling %s' % path)
                compile(path)
        except ImportError:
            print('Cython is not installed. Please install Cython first.')


class VendorCommand(BaseCommand):
    description = 'update hoedown files. Use `git submodule init`, '\
        '`git submodule update` and `git submodule foreach git pull origin master`'\
        ' to the most recent files'

    def run(self):
        os.system('git submodule update --init')
        os.system('git submodule foreach git pull origin master')
        files = []
        dest = os.path.join(dirname, 'hoedownpy/_hoedown/src')

        for path in ['vendor/hoedown/src/*', ]:
            files += glob.glob(os.path.join(dirname, path))

        for path in files:
            if os.path.exists(path):
                print('copy %s -> %s' % (path, dest))
                shutil.copy(path, dest)


class TestCommand(BaseCommand):
    description = 'run unit tests'
    def run(self):
        os.system('python tests/hoedown_test.py')


setup(
    name='hoedown',
    version=__version__,
    description='The Python binding for Hoedown, a markdown parsing library.',
    author='Hideo Hattori',
    author_email='hhatto.jp@gmail.com',
    url='https://github.com/hhatto/python-hoedown',
    license='MIT',
    long_description=open(os.path.join(dirname, 'README.rst')).read(),
    scripts=['scripts/hoedownpy'],
    cmdclass={
        'clean': CleanCommand,
        'compile_cython': CythonCommand,
        'update_vendor': VendorCommand,
        'test': TestCommand
    },
    ext_modules=[Extension('hoedown', [
        'hoedownpy/hoedown.c',
        'hoedownpy/wrapper.c',
        'hoedownpy/cb.c',
        'hoedownpy/_hoedown/src/html.c',
        'hoedownpy/_hoedown/src/stack.c',
        'hoedownpy/_hoedown/src/markdown.c',
        'hoedownpy/_hoedown/src/html_smartypants.c',
        'hoedownpy/_hoedown/src/html_blocks.c',
        'hoedownpy/_hoedown/src/escape.c',
        'hoedownpy/_hoedown/src/buffer.c',
        'hoedownpy/_hoedown/src/autolink.c'
    ], define_macros=[('inithoedownpy', 'inithoedown')])],
    classifiers = [
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: C',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.2',
        'Topic :: Text Processing :: Markup',
        'Topic :: Text Processing :: Markup :: HTML',
        'Topic :: Utilities'
    ]
)
