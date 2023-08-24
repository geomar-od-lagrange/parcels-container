#!/usr/bin/env python

# See also:
# https://github.com/ipython/ipykernel/issues/416

import argparse
import json
import pathlib

DEFAULT_PATH = "/usr/local/share/"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Fix Jupyter kernel spec for Conda env"
    )
    parser.add_argument(
        "--name", type=str, default="base", help="the Conda env name (will also be the Jupyter kernel spec name)"
    )
    args = parser.parse_args()
    return args


def get_kernel_dict(env_name: str):
    """Create kernel.json file contents.
    
    Parameters
    ----------
    env_name: str
    
    Returns
    -------
    dict
    """
    kernel_dict = {
        "argv": [
            "conda",
            "run",
            "-n",
            f"{env_name}",
            "python",
            "-m",
            "ipykernel_launcher",
            "-f",
            "{connection_file}",
        ],
        "display_name": f"{env_name}",
        "language": "python",
        "metadata": {"debugger": True},
    }
    return kernel_dict


def install_jupyter_kernel_spec():
    """Install kernel spec to default kernel spec location."""
    args = parse_args()
    env_name = args.name
    kernel_dict = get_kernel_dict(env_name=env_name)
    # https://github.com/ipython/ipykernel/blob/04e1d753e328194be391b62ffd22662f0fe6dc56/ipykernel/kernelspec.py#L14
    # https://github.com/jupyter/jupyter_client/blob/ac0045b81275c6eb833d98d97a4cee18fc1e3c3c/jupyter_client/kernelspec.py#L365
    # caveat: note, that Jupyter kernel spec paths are always lowercase and that Conda env paths are not
    #
    # $ conda env list
    # # conda environments:
    #   base                  *  /miniconda3
    #   geopMaGGP07              /miniconda3/envs/geopMaGGP07
    #   geopmaggp01              /miniconda3/envs/geopmaggp01
    # $ jupyter kernelspec list
    # Available kernels:
    #   python3        /miniconda3/lib/python3.9/site-packages/ipykernel/resources
    #   geopmaggp07    /usr/local/share/jupyter/kernels/geopmaggp07
    #
    kernel_name = env_name.lower() # jupyter kernel spec manager compatibility
    target_dir = pathlib.Path(DEFAULT_PATH) / "jupyter" / "kernels" / kernel_name
    target_dir.mkdir(exist_ok=True, parents=True)
    with open(target_dir / "kernel.json", mode="w") as kernel_file:
        json.dump(kernel_dict, kernel_file, indent=4)


if __name__ == "__main__":
    install_jupyter_kernel_spec()

