-- Definindo o ID da carta
local s, id = GetID()

-- Função inicial da carta
function s.initial_effect(c)
    -- Efeito de Invocação Ritual
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Efeito no cemitério
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost) -- Custo: remover a carta do próprio cemitério
    e2:SetTarget(s.banish_target)
    e2:SetOperation(s.banish_operation)
    c:RegisterEffect(e2)
end

-- Filtrar apenas monstros de Ritual que podem ser invocados
function s.filterRitualMonster(c, e, tp)
    return c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, true, false)
end

-- Alvo para o efeito de invocação ritual
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.filterRitualMonster, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
            and Duel.IsExistingMatchingCard(s.filterMaterial, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

-- Filtro para selecionar materiais de tributo (exceto monstros Link e incluindo monstros do oponente)
function s.filterMaterial(c)
    return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not c:IsType(TYPE_LINK) and c:GetLevel() > 0
end

-- Função de ativação do efeito de invocação ritual
function s.activate(e, tp, eg, ep, ev, re, r, rp)
    -- Selecionar o monstro de ritual para ser invocado
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.filterRitualMonster, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if g:GetCount() > 0 then
        local ritualMonster = g:GetFirst()

        -- Selecionar monstros do campo de ambos os lados ou cemitério para usar como materiais
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        local mg = Duel.SelectMatchingCard(tp, s.filterMaterial, tp, LOCATION_MZONE + LOCATION_GRAVE + LOCATION_MZONE, 0, 1, 99, nil)
        
        -- Verificar se os níveis dos materiais somam ou excedem o nível do monstro de ritual
        if mg:GetSum(Card.GetLevel) >= ritualMonster:GetLevel() then
            Duel.SpecialSummon(ritualMonster, SUMMON_TYPE_RITUAL, tp, tp, true, false, POS_FACEUP)
            Duel.Remove(mg, POS_FACEUP, REASON_COST)
        end
    end
end

-- Efeito de banir uma carta do oponente e adicionar à mão
function s.banish_target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_ONFIELD + LOCATION_GRAVE)
end

function s.banish_operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, 1, nil)
    if g:GetCount() > 0 then
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        Duel.SendtoHand(g, tp, REASON_EFFECT)
    end
end
