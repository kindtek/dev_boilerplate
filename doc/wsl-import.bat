@echo on
:redo
@REM set default variables. set default literally to default
SET default=default
SET username=default
SET groupname=dev
SET image_repo=kindtek
SET image_name=dbp:ubuntu-phat
SET mount_drive=C
SET install_directory=wsl-distros
SET save_directory=docker

SET "save_location=%install_location%\%save_directory%"
SET "install_location=%mount_drive%:\%install_directory%"
SET "distro=%image_name::=-%-%username%"
:header
SET save_location=%mount_drive%:\%save_directory%
SET image_save_path=%save_location%\%distro%.tar
SET install_location=%save_location%\%image_name::=-%
SET image_repo_and_name=%image_repo%/%image_name%
@REM TODO: update this to SET image_reponame=kindtek/dbp_git_docker

CLS
ECHO  ___________________________________________________________________ 
ECHO /                          DEV BOILERPLATE                          \
ECHO \___________________    WSL image import tool    ___________________/
ECHO   .................................................................
ECHO   .............    Default options in (parentheses)   .............
ECHO   .................................................................

IF %default%==config ( goto custom_config )

IF "%default%"=="" ( 
    default=confirm
    goto confirm
)

@REM default equals default if first time around
IF %default%==notdefault ( 
    default=defnotdefault
    goto confirm 
)

IF %default%==defnotdefault ( 
    IF %username%==default (
        username=dev0
        goto custom_config 
    )
    ELSE goto confirm
)

IF NOT %default%==default (goto %default%)


ECHO Press ENTER to use default image install configs or enter "config" to customize your image.
SET /p "default=(continue) > "

@REM catch when default configs NOT chosen AND second time around for user who chose to customize
@REM display header but skip prompt when user chooses to customize install
@REM IF %default%==config ( goto header )

:custom_config

if %default%==config (
ECHO username:
SET /p "username=(%username%) > "


ECHO group name:
SET /p "groupname=(%groupname%) > "


SET /p "image_repo=image repository: (%image_repo%) > "
SET /p "image_name=image name in %image_repo%: (%image_name%) > "
SET /p "save_directory=download folder: %mount_drive%:\(%save_directory%) > "
SET /p "install_directory=install folder: %mount_drive%:\%save_directory%\(%install_directory%) > "
SET install_directory=%mount_drive%:/

ECHO Save image as:
SET /p "distro=%save_location%\(%distro::=-%).tar > "
distro=%distro::=-%

)

@REM directory structure: 
@REM %mount_drive%:\%install_directory%\%save_directory%
@REM ie: C:\wsl-distros\docker

@REM below is for debug ..TODO: comment out eventually
ECHO setting up save directory (%save_directory%)...
mkdir %save_location%
ECHO setting up install directory (%install_directory%)...
mkdir %install_location%

:confirm
ECHO -----------------------------------------------------------------------------------------------------
wsl --list
ECHO -----------------------------------------------------------------------------------------------------
ECHO Check the list of current WSL distros installed on your system above. 
ECHO If %distro% is already listed above it will be REPLACED.
ECHO Use CTRL-C to quit now if this is not what you want.
ECHO _____________________________________________________________________________________________________
ECHO =====================================================================================================
ECHO CONFIRM YOUR SETTINGS
ECHO username: %username%
ECHO group name: %groupname%
SET image_repo_image_name=%image_repo%/%image_name%
ECHO image source/name: %image_repo_image_name%
SET image_save_path=%save_location%\%distro%.tar
ECHO image destination: %image_save_path%
ECHO WSL alias : %distro% 
ECHO -----------------------------------------------------------------------------------------------------

ECHO =====================================================================================================
ECHO pulling image (%image_repo_image_name%)...
docker save %image_repo_image_name% \> %image_save_path%
ECHO saving as %image_save_path%...
ECHO initializing the image container
docker load -i %image_save_path%\%distro%.tar
_WSL_DOCKER_IMG_ID=| docker ps -alq 
del %image_save_path%\%distro%.tar
docker export -o %_WSL_DOCKER_IMG_ID% > %image_save_path%\%distro%.tar
ECHO DONE

:install_prompt
ECHO Would you still like to continue (yes/no/redo)?
SET /p "continue="

@REM if label exists goto it
goto %continue%

@REM otherwise... use the built in error message and repeat install prompt
goto install_prompt

@REM EASTER EGG: typing yes at first prompt bypasses cofirm and restart the default distro
:yes


:install
ECHO killing current the WSL %distro% process if it is running...
wsl --terminate %distro%
ECHO DONE

@REM ECHO killing all WSL processes...
@REM wsl --shutdown
@REM ECHO DONE

if NOT default==yes (
    ECHO deleting WSL distro %distro% if it exists...
    wsl --unregister %distro%
    ECHO DONE

    ECHO importing  %distro%.tar to %install_location% as %distro%
    wsl --import %distro% %install_location% %image_save_path%
    ECHO DONE
)

ECHO setting  %distro% as default
wsl --set-default %distro%
ECHO DONE

wsl --shutdown
wsl -l -v
wsl 

:quit
:no
echo goodbye
