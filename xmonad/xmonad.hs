import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Fullscreen (fullscreenFull, fullscreenSupport)
import XMonad.Layout.TwoPane (TwoPane(..))
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import System.IO

myLayoutHook =
        smartBorders
        $ mkToggle (NOBORDERS ?? FULL ?? EOT)
        $ Tall 1 (10/100) (50/100)
        ||| TwoPane (10/100) (50/100)

main = do
        xmproc <- spawnPipe "xmobar"
        xmonad $ docks $ fullscreenSupport $ defaultConfig
                { layoutHook = avoidStruts myLayoutHook
                , terminal = "gnome-terminal"
                , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
                , modMask = mod4Mask    -- Rebind Mod to Super
                } `additionalKeys`
                [ ((mod4Mask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
                , ((mod4Mask .|. shiftMask, xK_p), spawn "sleep 0.2; scrot -s")
                , ((mod4Mask, xK_f), sendMessage $ Toggle FULL)
                , ((0, xK_Print), spawn "scrot")
                ]
