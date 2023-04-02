
print("Loading LiveTexture MatProxy")
matproxy.Add({
    name = "LiveTexture",
    init = function(self, mat, values)
        print("MatProxy Init")
        self.ResultTo = values.resultvar
    end,
    bind = function(self, mat, ent)
        if ent.LiveTexture then
            mat:SetTexture(self.ResultTo, ent.LiveTexture)
        end
    end
})