local s,id=GetID()
function s.initial_effect(c)
    -- Habilitar Invocação-Link
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x11f),1,1) -- Invocação-Link com 1 monstro Normal ou Ritual Invocado do archetype "Nephthys"

    -- Efeito ao ser Link Summoned: Invocar 2 monstros "Nephthys"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Efeito no Cemitério: Banir para destruir e invocar "Nephthys"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    e2:SetCountLimit(1,id+100)
    c:RegisterEffect(e2)
end
s.listed_series={0x11f}  -- Série Nephthys

-- Condição para Invocar 2 monstros "Nephthys"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Filtro para monstros "Nephthys"
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x11f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Alvo para invocar 2 monstros "Nephthys"
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- Efeito de Invocação Especial de 2 monstros "Nephthys"
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
    if #g>=2 then
        local sg=g:Select(tp,2,2,nil)
        for tc in aux.Next(sg) do
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
        Duel.SpecialSummonComplete()
    end
end

-- Alvo para o efeito no cemitério: Destruir 2 "Nephthys" e invocar outro "Nephthys"
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND+LOCATION_MZONE,0,2,nil)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_HAND+LOCATION_MZONE)
end

-- Filtro para monstros "Nephthys" com 2400 ATK
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x11f) and c:IsAttack(2400) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
end

-- Operação: Destruir 2 cartas "Nephthys", Invocar um monstro com 2400 ATK e destruir 2 cartas no campo
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Destroy(Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND+LOCATION_MZONE,0,2,2,nil),REASON_EFFECT)>0 then
        local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g:GetFirst(),SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
            -- Opcional: destruir 2 cartas no campo
            local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
            if #dg>0 then
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end
