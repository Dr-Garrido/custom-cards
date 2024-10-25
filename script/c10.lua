-- Samuel card Maker
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    --e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsType,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil,TYPE_MONSTER)
    return g:GetCount() * 500
	
end
---------------------------------------------