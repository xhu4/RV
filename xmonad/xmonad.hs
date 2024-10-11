import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Fullscreen (fullscreenFull, fullscreenSupport)
import XMonad.Layout.TwoPane (TwoPane(..))
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import System.IO

myLayoutHook =
        smartBorders
        $ mkToggle (NOBORDERS ?? FULL ?? EOT)
        $ ThreeCol 1 (5/100) (1/3)
        ||| TwoPane (10/100) (50/100)
        ||| Tall 1 (3/100) (1/2)

main = do
        xmproc <- spawnPipe "xmobar"
        xmonad $ docks $ fullscreenSupport $ def
                { layoutHook = avoidStruts myLayoutHook
                , terminal = "gnome-terminal"
                , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
                , modMask = mod4Mask    -- Rebind Mod to Super
                } `additionalKeys`
                [ ((mod4Mask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
                , ((mod4Mask .|. shiftMask, xK_p), spawn "sleep 0.2; scrot -s '/tmp/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f'")
                , ((mod4Mask, xK_F4), spawn "shutdown -P now")
                , ((mod4Mask, xK_f), sendMessage $ Toggle FULL)
                , ((mod4Mask, xK_s), spawn "xrandr --auto")
                , ((0, xK_Print), spawn "scrot")
                ]
