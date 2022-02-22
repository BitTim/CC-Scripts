local M = {}

M.setLayers = nil
M.getLayers = nil
M.savePath = ""


function M.init(setLayers, getLayers)
    M.setLayers = setLayers
    M.getLayers = getLayers
end

function M.new()

end

function M.save(saveAs)
    if saveAs == nil then saveAs = false end
end

function M.saveAs()
    M.save(true)
end

function M.open()

end

return M