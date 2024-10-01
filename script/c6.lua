local s,id=GetID()
function s.initial_effect(c)
    -- Efeito: Comprar 10 cartas, embaralhar as cartas do oponente, e invocar 3 monstros do Extra Deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Custo: Remova a carta da mão para o cemitério
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.filter(c,e,tp)
    -- Filtrar apenas monstros que podem ser invocados
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Verifica se o jogador pode comprar 10 cartas
    if chk==0 then return Duel.IsPlayerCanDraw(tp,10) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,10)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Comprar 10 cartas
    Duel.Draw(tp,10,REASON_EFFECT)

    -- O oponente embaralha todas as cartas da mão e no campo no deck
    local opponent = 1 - tp
    local hand = Duel.GetFieldGroup(opponent,LOCATION_HAND,0)
    local field = Duel.GetFieldGroup(opponent,LOCATION_ONFIELD,0)
    local all_cards = hand + field
    
    if #all_cards > 0 then
        Duel.SendtoDeck(all_cards,nil,2,REASON_EFFECT)
    end

    -- Invocar 3 monstros do Extra Deck ignorando suas condições de invocação
    local extra_deck = Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if #extra_deck >= 3 then
        for i=1,3 do
            local card = extra_deck:Select(tp, 1, 1, nil):GetFirst()
            if card then
                -- Ignora as condições de invocação para monstros do Extra Deck
                Duel.SpecialSummon(card, 0, tp, tp, false, false, POS_FACEUP)
            end
        end
    end
end
