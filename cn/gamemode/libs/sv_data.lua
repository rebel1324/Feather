cn.data = cn.data or {}
cn.data.buffer = cn.data.buffer or {}
cn.data.baseDir = "cn"

function cn.data.setBaseDir(directory)
	cn.data.baseDir = directory
	file.CreateDir(cn.data.baseDir)
end

function cn.data.write(key, value)
	value = {value}
	file.Write(cn.data.baseDir.."/"..key..".txt", util.Compress(pon.encode(value)))
end

function cn.data.read(key, default)
	local content = file.Read(cn.data.baseDir.."/"..key..".txt", "DATA")
		if (!content) then return default end
	local decoded = pon.decode(util.Decompress(content))

	return decoded != nil and decoded[1] or default
end