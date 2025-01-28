# Amoeba on Bochs

This repository contains files to run an Amoeba cluster on Bochs (native or through Docker).
Enjoy exploring the cluster and trying Python 1.1 in its natural habitat. 

# Running Amoeba in Docker Containers

## Building the Image locally

To build the Amoeba image locally, execute the following in the root folder of the repository:

`sudo docker build -t amoeba .`

## Running a Single Machine

Assuming you build the image locally under the name `amoeba`, you can run the image by executing the following:

`sudo docker compose -f main-machine-compose.yml up`

You can now connect to the Bochs machine running Amoeba using a VNC viewer on `localhost:5900`.

# Running Amoeba directly in Bochs

## Installation

### Dependencies
* BOCHS 2.7 or later
* SDL2-dev installed if you want to use it for the graphical interface

### Building Bochs
1. Get a bochs source package > 2.7
2. Unpack it
3. Run the configure script with the following options "--enable-smp --enable-ne2000". If you want to have sdl as your gui you also have to add "--with-sdl2". --enable-smp enables multiprocessing simulation so we can have multiple processors in the processor pool. --enable-ne2000 enables an old network card interface which amoeba can deal with.
4. run "make && make install" Note that "make install" may need super privilege.

## Starting Machines Manually
You have to start bochs as the super user to make the ne2k driver work. You also have to set the `AMOEBA_FILES` env variable to the installation_files directory, so, given you are in one of the machine folders, you can start the machine using:

```
sudo env "AMOEBA_FILES=../../installation_files/" bochs -q
```

Credentials for all machines are: user: "Daemon" pwd: "".

### main_machine
Open a terminal and navigate to the machines/main_machine folder. Start bochs with "sudo bochs" and select starting the machine and wait until it shows a login. Credentials see above.

### workstation
Open a terminal and navigate to the machines/workstation folder. Start bochs with "sudo bochs" and select starting the machine. When the emulation powers up and amoeba asks you for a kernel to load type in "workstation". It will now load a workstation an register itself with the "main" machine.

### pool
Same instructions as for the workstation but you enter "pool" when asked for a kernel to load.

# Things to do in Amoeba

* Explore the /super directory and try reading proc files on other machines
* Try Python 1.1 and explore the Python interface for Amoeba's interesting OS principles.
* Start the Amoeba Worm (your systems will die, but its fun to watch it spread). For details refer to the system administrator guide.

For more extensive information about the possible things on Amoeba, take a look at the three Guides in the documentation folder.

## Package structure

* documentation: Contains the official manuals for an Amoeba installation.
* installation_files: Contains prepared .img files which e.g. include kernals or ramdisks needed to boot an Amoeba system.
* machines: Includes a subfolder for each machine type. If you want to create another pool or workstation you can simply copy the folder and adjust the bochsrc.txt. In the bochsrc file you have to pick another MAC address. If you want to use the machine in your Amoeba system you have to add it first. You can find an extensive guide how to do that in the SystemAdministratorGuide.pdf.
* source: The complete Amoeba source code to browse and understand the Amoeba system. Currently this is not included in the package but you can find the source on: ftp://ftp.cs.vu.nl/pub/amoeba/amoeba5.3/src/.

## Getting files onto the main machine

This tedious task requires some patience currently. If someone finds an easier way please contact me. Otherwise you have to do it as described below, as long BOCHS doesn't support tape drives.
What we will use is an Amoeba tool which is normally used to load the ramdisks. We will simply use the headers of the ramdisk floppies and attach our own payload.

1. Get your file in tar format.
2. Split that file in 1474048 byte chunks. This is the size of a floppy (1,474,560 bytes) minus the size of the ramdisk header (512 bytes).
3. The last file will probably not have 1474048 bytes so you have to fill it up with padding bytes. You can get the correct bytes from the padding file in the installation_files directory.
4. If you have an odd number of files create another 1474048 bytes file only containing padding bytes.
5. Merge amoeba.header.0.img and the first chunk and amoeba.header.1.img and the second chunk and so forth. You need that because the data loader script will always request both floppies.

Now we're done with the creation of the floppies. Let's load them.

1. Start the main machine
2. Use the BOCHS gui to insert your first floppy.
3. Use the following command to start reading in the files: readvol /super/hosts/triton/floppy:00 >> {path to a file where you want to store the bytes of the first to chunks}
4. The script will read in the first floppy and then ask you for the second one. Again use the BOCHS gui to insert the second one.
5. Repeat for all your pairs of floppies.
6. Then you can use the cat command to reassemble them to one file. You might run out of memory. Then try to reassemble them to 2-3 bigger files first and assemble them to the original file afterwards.
7. Now you can use the od command to cut your file to the original size. You might want to use tail and od to check if the last bytes do match.
8. Use tar to regain your files.

# Open Issues
Currently the installed Amoeba kernel came precompiled in a verbose mode. One should recompile the kernel in quiet mode to avoid the RPC notifications spamming the screen. One can find the macro option in the source code. However this is not easy, as the tools for compiling Amoeba are on the Amoeba system itself. To understand why this is a problem, see the section about loading files into Amoeba.
