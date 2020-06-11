# Arpeggio

[![Build Status](https://travis-ci.org/harryjubb/arpeggio.svg?branch=master)](https://travis-ci.org/harryjubb/arpeggio)

## Outline

Arpeggio calculates interatomic contacts based on the rules defined in [CREDO](http://marid.bioc.cam.ac.uk/credo). The program is freely available and requires only Open Source dependencies.

If you make use of Arpeggio, please cite the following article:

Harry C Jubb, Alicia P Higueruelo, Bernardo Ochoa-Montaño, Will R Pitt, David B Ascher, Tom L Blundell,
Arpeggio: A Web Server for Calculating and Visualising Interatomic Interactions in Protein Structures,
Journal of Molecular Biology,
Volume 429, Issue 3,
2017,
Pages 365-371,
ISSN 0022-2836,
https://doi.org/10.1016/j.jmb.2016.12.004.
(http://www.sciencedirect.com/science/article/pii/S0022283616305332)

## Getting Started

**Stuck?** Start here, and see also the [FAQ](https://github.com/harryjubb/arpeggio#frequently-asked-questions).

### Web Interface

If you would like to run Arpeggio on a small number of individual structures, the easiest way to get started is to use the [web interface](http://biosig.unimelb.edu.au/arpeggioweb/).

### Programmatically

If you need to use Arpeggio programmatically or to run for many structures:

The easiest way to get started is using [Docker](https://www.docker.com/).

#### Using the public Docker image

Arpeggio's Docker image is [hosted on DockerHub](https://hub.docker.com/r/harryjubb/arpeggio/). To use:

    docker pull harryjubb/arpeggio

Once downloaded, Arpeggio can be run using:

    docker run --rm -v "$(pwd)":/run -u `id -u`:`id -g` -it harryjubb/arpeggio python arpeggio.py /run/1XKK.pdb -s RESNAME:FMM -v

Breaking this down:

- `docker run`: run the image
- `--rm`: clean up the Docker container when the run is finished
- `-v`: bind-mount a host machine directory in the container (with your input files, and where your output files will appear). In this case, the current working directory will be mounted to `/run` in the container
- ``-u `id -u`:`id -g` ``: Set the user and group in the Docker container to match the host user and group running the container, so that any files written are written as the correct user
- `-it`: interactive run with a pseudo-TTY terminal
- `arpeggio`: the name of the built Docker image
- `python arpeggio.py`: run Arpeggio
- `/run/1XKK.pdb`: a PDB file in our mounted host directory
- `-s RESNAME:FMM -v`: options passed to Arpeggio, in this case, to calculate interactions for residue with name FMM, and show verbose output

#### Building the Docker image

You can build the docker image from inside this repository with:

    docker build -t 'arpeggio' .

#### Installing without Docker

If it is not possible to use Docker, please read on for dependencies for manual installation.

## Dependencies

Arpeggio is written in Python and currently has the following dependencies:

### Dependencies

- Python (v2.7)
- Numpy
- BioPython (>= v1.60)
- OpenBabel (with Python bindings)

### Recommended
- PyMOL (for visualising contacts)

Arpeggio may work with earlier versions of BioPython, however these haven't been tested. It is recommended that each dependency be the latest version.

## Running

`python arpeggio.py pdb [options]`

Use `python arpeggio.py -h` for available options.

Arpeggio doesn't do any checking of your PDB structure, other than what BioPython does by default. Alternate locations and missing density are not explicitly accounted for and may result in anomalous results. Please use with caution.

## Frequently Asked Questions

**See also the [GitHub issue questions](https://github.com/harryjubb/arpeggio/issues?utf8=%E2%9C%93&q=label%3Aquestion).**

### BioPython/OpenBabel are complaining about my structure, what's happening?

Both can be picky about the format of PDB files, for example atom serials must be unique (to map between BioPython and OpenBabel structures), and other issues can raise BioPython errors.

The `clean_pdb.py` script in https://github.com/harryjubb/pdbtools resolves a number of common errors; if your structure doesn't work, try using that first before trying Arpeggio on the cleaned structure.

### My results don't match the output of the web server, what's happening?

In order to prevent errors from BioPython/OpenBabel (described above) causing Arpeggio to fail, the web server preprocesses input PDB files before running Arpeggio. The `clean_pdb.py` script in https://github.com/harryjubb/pdbtools provides this functionality outside of the web server.

Please also be aware that changing command line options may also result in differences from the web server's output. Arpeggio is run on the web server with the `-wh` option, and an optional selection.

### What happens if my structure does or doesn't have hydrogens?

Arpeggio will add hydrogens using OpenBabel if none are present in the input structure. If your input structure has at least one hydrogen, then hydrogen addition is skipped, and input hydrogens are used. Arpeggio will not add any missing hydrogens to any input structure with at least one hydrogen in (e.g. protein hydrogens will not be added if the ligand is hydrogenated). It is advisable to pre-prepare input structures with a robust hydrogen addition method before running Arpeggio.

## Output Files

### `*.ari`

Atom-aromatic ring interactions.

| Column | Datatype | Description |
| ------ | -------- | ----------- |
| Atom   | string `<chain_id>/<res_num><ins_code (stripped)>/<atom_name>` | Uniquely identifies an atom |
| Ring ID | integer | Internal number used to identify the aromatic ring |
| Ring centroid | list | 3D coordinates of the centre of the ring |
| Interaction type | list | Type(s) of interaction this atom/ring are making |

### `*.ri`

Aromatic ring-aromatic ring interactions.

| Column | Datatype | Description |
| ------ | -------- | ----------- |
| Ring 1 ID | integer | Internal number used to identify the first aromatic ring |
| Ring 1 Residue   | string `<chain_id>/<res_num>` | Uniquely identifies the first ring's residue |
| Ring 1 centroid | list | 3D coordinates of the centre of the first ring |
| Ring 2 ID | integer | Internal number used to identify the second aromatic ring |
| Ring 2 Residue   | string `<chain_id>/<res_num>` | Uniquely identifies an the second ring's residue |
| Ring 2 centroid | list | 3D coordinates of the centre of the second ring |
| Inter or intra residue | string from (`INTER`, `INTRA_RESIDUE`) | States whether this ring-ring interaction is within the same residue (e.g. within a small molecule ligand), or between two different residues |
| Interacting entities | string from (`INTER`, `INTRA_NON_SELECTION`, `INTRA_SELECTION`) | Distinguishes how this interacting ring pair relates to the selected atoms: see below |

### `*.rings`

Aromatic rings found in the structure

| Column | Datatype | Description |
| ------ | -------- | ----------- |
| Ring ID | integer | Internal number used to identify the ring |
| Ring Residue   | string `<chain_id>/<res_num>` | Uniquely identifies the ring's residue |
| Ring centroid | list | 3D coordinates of the centre of the ring |

### `*.atomtypes`

Atom types for all of the atoms for which interactions are calculated for. This includes the selected atoms, and the atoms that those atoms interact with.

| Column | Datatype | Description |
| ------ | -------- | ----------- |
| Atom   | string `<chain_id>/<res_num><ins_code (stripped)>/<atom_name>` | Uniquely identifies an atom |
| Atom types | list | All the atom types that this atom possesses |

### `*.contacts`

Pairwise contacts between two individual atoms.

| Column | Datatype | Description |
| ------ | -------- | ----------- |
| Atom 1 | string `<chain_id>/<res_num><ins_code (stripped)>/<atom_name>` | Uniquely identifies the first atom in this contact |
| Atom 2 | string `<chain_id>/<res_num><ins_code (stripped)>/<atom_name>` | Uniquely identifies the second atom in this contact |
| Clash | boolean::integer | Denotes if the covalent radii of the two atoms are clashing, i.e. steric clash |
| Covalent | boolean::integer | Denotes if the two atoms appear to be covalently bonded |
| VdW Clash | boolean::integer | Denotes if the van der Waals radii of the two atoms are clashing |
| VdW | boolean::integer | Denotes if the van der Waals radii of the two atoms are interacting |
| Proximal | boolean::integer | Denotes the two atoms being > the VdW interaction distance, but with in 5 Angstroms of each other |
| Hydrogen Bond | boolean::integer | Denotes if the atoms form a hydrogen bond |
| Weak Hydrogen Bond | boolean::integer | Denotes if the atoms form a weak hydrogen bond |
| Halogen Bond | boolean::integer | Denotes if the atoms form a halogen bond |
| Ionic | boolean::integer | Denotes if the atoms may interact via charges |
| Metal Complex | boolean::integer | Denotes if the atoms are part of a metal complex |
| Aromatic | boolean::integer | Denotes two aromatic ring atoms interacting |
| Hydrophobic | boolean::integer | Denotes two hydrophobic atoms interacting |
| Carbonyl | boolean::integer | Denotes a carbonyl-carbon:carbonyl-carbon interaction |
| Polar | boolean::integer | Less strict hydrogen bonding (without angle terms) |
| Weak Polar | boolean::integer | Less strict weak hydrogen bonding (without angle terms) |
| Interacting entities | string from (`INTER`, `INTRA_NON_SELECTION`, `INTRA_SELECTION`, `SELECTION_WATER`, `NON_SELECTION_WATER`, `WATER_WATER`) | Distinguishes how this atom pair relates to the selected atoms: see below |

**Clash, Covalent, VdW Clash, VdW and Proximal interactions are mutually exclusive: Other interactions can occur simultaneously.**

Entity interactions:

- `INTER`: Between an atom from the user's selection and a non-selected atom
- `INTRA_SELECTION`: Between two atoms both in the user's selection
- `INTRA_NON_SELECTION`: Between two atoms that are both not in the user's selection
- `SELECTION_WATER`: Between an atom in the user's selection and a water molecule
- `NON_SELECTION_WATER`: Between an atom that is not in the user's selection and a water molecule
- `WATER_WATER`: Between two water molecules

### `*.bs_contacts`

As with `*.contacts`, but only including interactions in the binding site (i.e. interactions involving atoms that were selected by the user, with atoms not selected by the user, as opposed to any intra-selection interactions.

### `*.sift`

Interaction fingerprints for individual atoms. These are binary (i.e., on/off) indications of an atom's interaction, not counts.

| Column | Datatype | Description |
| ------ | -------- | ----------- |
| Atom | string `<chain_id>/<res_num><ins_code (stripped)>/<atom_name>` | Uniquely identifies the atom |
| Clash | boolean::integer | Denotes if the atom is involved in a steric clash |
| Covalent | boolean::integer | Denotes if the atom appears to be covalently bonded |
| VdW Clash | boolean::integer | Denotes if the van der Waals radius of the atom is clashing with one or more other atoms |
| VdW | boolean::integer | Denotes if the van der Waals radius of the the atom is interacting with one or more other atoms |
| Proximal | boolean::integer | Denotes if the atom is > the VdW interaction distance, but with in 5 Angstroms of other atom(s) |
| Hydrogen Bond | boolean::integer | Denotes if the atom forms a hydrogen bond |
| Weak Hydrogen Bond | boolean::integer | Denotes if the atom forms a weak hydrogen bond |
| Halogen Bond | boolean::integer | Denotes if the atom forms a halogen bond |
| Ionic | boolean::integer | Denotes if the atom may interact via charges |
| Metal Complex | boolean::integer | Denotes if the atom is part of a metal complex |
| Aromatic | boolean::integer | Denotes an aromatic ring atom interacting with another aromatic ring atom |
| Hydrophobic | boolean::integer | Denotes hydrophobic interaction |
| Carbonyl | boolean::integer | Denotes a carbonyl-carbon:carbonyl-carbon interaction |
| Polar | boolean::integer | Less strict hydrogen bonding (without angle terms) |
| Weak Polar | boolean::integer | Less strict weak hydrogen bonding (without angle terms) |

### `*.specific.sift`

Interaction fingerprints for individual atoms. These are binary (i.e., on/off) indications of an atom's interaction, not counts.

The columns match the `*.sift` files, but the first 15 columns (after the atom identifier) denote only interactions between the selection made by the user, and non-selection atoms; the second 15 columns indicate interactions made within the selection made by the user; and the third 15 columns indicate interactions made with water only.

### `*.siftmatch`, `*.polarmatch`

These files are for testing purposes.
