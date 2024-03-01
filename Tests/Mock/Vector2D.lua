local dummySingleton = {
    Subtract = function (self, other) return self end,
    GetXY = function (self) return 0, 0 end
}

function CreateVector2D(x, y)
    return dummySingleton
end

