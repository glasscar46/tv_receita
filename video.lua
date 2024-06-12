local isFullScreen = false

event.register(function(evt)
    if evt.class == 'ncl' and evt.type == 'attribution' and evt.name == 'playVideoEvent' then
        local url = evt.value
        ncl.set("videoPlayer", "src", url)
        ncl.play("videoPlayer")
        ncl.set("videoPlayer", "bounds", "0,0,100%,100%")
        isFullScreen = true
    elseif evt.class == 'key' and evt.type == 'press' and evt.key == "BACK" and isFullScreen then
        ncl.stop("videoPlayer")
        ncl.set("videoPlayer", "bounds", "0,55%,100%,45%")
        event.post {
            class = 'ncl',
            type = 'attribution',
            name = 'backToDetailsEvent'
        }
        isFullScreen = false
    end
end)
