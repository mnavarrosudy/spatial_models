# Spatial models

This repository contains scripts coded in Julia for various spatial modeling projects. To download and install Julia on your machine, please follow [these instructions](https://julialang.org/downloads/).

## `BBGD` folder

This folder contains testing code for the project "Bridges in Bangladesh" in collaboration with Alejandro Molnar and Forhad Shilpi.

### `toy_model_pkg` folder

This folder contains a proof of concept for a regional quantitative spatial model adapted from Redding (2016). The code in this folder proposes a methodology to flexibly estimate transportation parameters. Specifically, it allows for the evaluation of the Generalized Method of Moments (GMM) function for different sets of parameters, thereby testing whether the model is identified.

### How to download the `toy_model_pkg` folder?

**macOS**

1. Open Terminal.
2. Use `cd` command to set your preferred working directory where you want to download the folder.

    Example:
    ```
    cd /Users/mnavarrosudy/Desktop
    ```

3. Download the folder by running the following command:

```
curl -LO https://github.com/mnavarrosudy/spatial_models/raw/main/BBGD/toy_model_pkg.zip
```
    
- Note: `curl` does not follow HTTP redirections by default, so we use the `-L/--location` option to enable this behavior.

4. Unzip the folder by running the following command:

```
unzip toy_model_pkg.zip
```

**Windows**

1. Open Windows PowerShell.
2. Use the `cd` command to set your preferred working directory and where you want to download the folder.

    Example:
    ```
    cd C:\\Users\\mnavarrosudy\\Desktop
    ```

3. Download the folder by running the following commands:

    3.1. Set the final destination for the folder  
    ```
    $destfinal = "C:\Users\name-of-your-machine\Desktop"
    ```

    3.2. Set the URL from we are downloading the folder .zip file
    ```
    $url = "https://github.com/mnavarrosudy/spatial_models/raw/main/BBGD/toy_model_pkg.zip"
    ```

    3.3. Set the full pathname for the folder .zip file
    ```
    $dest = "C:\Users\name-of-your-machine\Desktop\toy_model_pkg.zip"
    ```

    3.4. Download the folder .zip file
    ```
    Invoke-WebRequest -Uri $url -OutFile $dest
    ```

4. Unzip the folder by running the following command:

```
Expand-Archive $dest -DestinationPath $destfinal
```

### How to run the scripts in `toy_model_pkg`?

**macOS**

1. Open Terminal.
2. Type `julia` to launch Julia REPL from the Terminal.    
    - Note: If `julia` is not in the PATH you will see a message saying *command not found: julia*. To include `julia` in the PATH, type: `export PATH=$PATH:/Applications/Julia-x.x.app/Contents/Resources/julia/bin`, replacing x.x with the number of your Julia version. Then, type `julia` again.

3. Type `pwd()` to print the current working directory.
4. Find the full pathname on your machine for the directory `~/toy_model_pkg/code`. For example, on my machine, the full `"pathname"` to that directory is `"/Users/mnavarrosudy/Desktop/toy_model_pkg/code"`.
5. Set the working directory as the folder where the scripts are located. To do this, type: `cd("pathname")` where `"pathname"` is the directory you identified in step 4.

    Example:
    ```
    julia> cd("/Users/mnavarrosudy/Desktop/toy_model_pkg/code")
    ```

6. The main script in `~/toy_model_pkg/code` is `run_model.jl`. We need to load that script to make its functions available. To do this, type: `include("run_model.jl")`. 
```
include("run_model.jl")
```
- Note: You should see the message *"run_model (generic function with 1 method)"*. This is the function we will use to run the experiments.

7. The function `run_model(experiment_num)` receives one input, `experiment_num`, which indicates the ID of the experiment you want to run. For example, to run the experiment with `experiment_num = 15`, type:
```
run_model(15)
```
- Note 1: Consult the file `~/toy_model_pkg/data/experiments.txt` to see the experiments set by default. 
- Note 2: The ID of the experiments is the first column in the file `~/toy_model_pkg/data/experiments.txt`. The rest of the columns represent the values of the parameters.
- Note 3: The results are stored in `~/toy_model_pkg/results/gmm_values.txt`.

**Windows**

1. Open Windows PowerShell.
2. Type `julia` to launch Julia REPL from the PowerShell.
3. Type `pwd()` to print the current working directory.
4. Find the full pathname on your machine for the directory `~\\toy_model_pkg\\code`. For example, on my machine, the full `"pathname"` to that directory is `"C:\\Users\\mnavarrosudy\\Desktop\\toy_model_pkg\\code"`.
5. Set the working directory as the folder where the scripts are located. To do this, type: `cd("pathname")` where `"pathname"` is the directory you identified in step 4.

    Example:
    ```
    julia> cd("C:\\Users\\mnavarrosudy\\Desktop\\toy_model_pkg\\code")
    ```

6. The main script in `~\\toy_model_pkg\\code` is `run_model.jl`. We need to load that script to make its functions available. To do this, type: `include("run_model.jl")`. 
```
include("run_model.jl")
```
- Note: You should see the message *"run_model (generic function with 1 method)"*. This is the function we will use to run the experiments.

7. The function `run_model(experiment_num)` receives one input, `experiment_num`, which indicates the ID of the experiment you want to run. For example, to run the experiment with `experiment_num = 15`, type:
```
run_model(15)
```
- Note 1: Consult the file `~\\toy_model_pkg\\data\\experiments.txt` to see the experiments set by default. 
- Note 2: The ID of the experiments is the first column in the file `~\\toy_model_pkg\\data\\experiments.txt`. The rest of the columns represent the values of the parameters.
- Note 3: The results are stored in `~\\toy_model_pkg\\results\\gmm_values.txt`.