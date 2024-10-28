-- Megumin's Explosion Spell
local s,id=GetID()
function s.initial_effect(c)
    -- Ativar: destrua todos os cards no campo se você controlar "Megumin"
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
    e1:SetCountLimit(1,{id,1,EFFECT_COUNT_CODE_DUEL}) -- Limite de 1 vez por duelo
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end

-- Condição para ativação: você deve controlar um card "Megumin"
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.meguminfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Filtro para verificar se você controla "Megumin"
function s.meguminfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x998) and c:IsType(TYPE_MONSTER)
end

-- Alvo e operação para destruir todos os cards no campo
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
