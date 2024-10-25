-- Wrath of Nephthys
local s,id=GetID()
function s.initial_effect(c)
    -- Ativar
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    -- Permitir ativação de "Nephthys" Spell/Trap Cards da mão
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -- Uma vez por turno: destrua 1 monstro na mão ou no campo e Special Summon 1 "Nephthys" Spellcaster do Deck
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Se um "Nephthys" Ritual Monster(s) for Special Summoned (exceto durante o Damage Step): destrua esta carta e 1 carta em cada campo e Special Summon 1 "Nephthys" com 2400 ATK
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0x11f}  -- Série Nephthys

-- Condição para ativação da mão: verifique se o jogador controla um card "Nephthys"
function s.handcon(e)
    return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x11f) end, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

-- e2: Destroi 1 monstro na mão ou no campo e Special Summon 1 "Nephthys" Spellcaster do Deck
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
        -- Special Summon 1 "Nephthys" Spellcaster do Deck
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- e3: Condição para destruição da carta e Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsSetCard(0x11f) and c:IsType(TYPE_RITUAL) end, 1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,0)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x11f) and c:GetAttack()==2400 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Destroy(c,REASON_EFFECT)~=0 then
        -- Destroi 1 carta em cada campo
        local g1=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,1,nil)
        local g2=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
        g1:Merge(g2)
        if #g1>0 then
            Duel.Destroy(g1,REASON_EFFECT)
        end
        -- Special Summon 1 "Nephthys" com 2400 ATK
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end
