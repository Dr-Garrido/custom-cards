-- Wrath of Nephthys
local s,id=GetID()
function s.initial_effect(c)
    -- Activação de "Nephthys" Spell/Trap Cards da mão durante a Main Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_HAND,0)
    e1:SetTarget(s.target)
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

    -- Você pode controlar apenas 1 "Wrath of Nephthys"
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EFFECT_MAXIMUM)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

-- e1: Alvo para ativação de "Nephthys" Spell/Trap Cards da mão
function s.target(e,c)
    return c:IsSetCard(0x11f) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end

-- e2: Destroi 1 monstro na mão ou no campo e Special Summon 1 "Nephthys" Spellcaster do Deck
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
        if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
            -- Special Summon 1 "Nephthys" Spellcaster do Deck
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(0x11f) and c:IsType(TYPE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,tp,LOCATION_DECK,0,1,1,nil)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

-- e3: Condição para destruição da carta e Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsSetCard(0x11f) and c:IsType(TYPE_RITUAL) end, 1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spfilter(c)
    return c:IsSetCard(0x11f) and c:GetAttack()==2400 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        -- Destroi esta carta
        Duel.Destroy(c,REASON_EFFECT)
        -- Destroi 1 carta em cada campo
        local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
        -- Special Summon 1 "Nephthys" com 2400 ATK
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
