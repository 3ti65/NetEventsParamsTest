class "StringExtensions"

function string:normalizePath()
	if self == nil then
		return ""
	end
	local normalizedString = self
	
	normalizedString = string.gsub(normalizedString, "/", "_")
    normalizedString = string.gsub(normalizedString, "-", "_")
	return normalizedString
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

return StringExtensions