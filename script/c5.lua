--ネフティスの輪廻
--Rebirth of Nephthys,,,, but is RISING
local s,id=GetID()
function s.initial_effect(c)
    -- Adiciona a condição para Invocação Ritual usando materiais do cemitério e da mão
    Ritual.AddProcGreater({
        handler=c,
        filter=s.ritualfil,
        stage2=s.stage2,
        location=LOCATION_HAND|LOCATION_GRAVE
    })
end

s.listed_series={0x11f} -- Define a série "Nephthys"
s.fit_monster={88176533,24175232} -- IDs dos monstros que podem ser usados como materiais

-- Filtro para monstros Ritual Nephthys
function s.ritualfil(c)
    return c:IsSetCard(0x11f) and c:IsRitualMonster()
end

-- Filtro para destruir uma carta Nephthys na mão
function s.mfilter(c)
    return c:IsSetCard(0x11f) and c:IsAbleToGraveAsCost()
end

function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp)
    -- Verifica se existem materiais válidos no cemitério
    if mg:IsExists(s.mfilter,1,nil) then
        -- Cria um grupo de cartas "Nephthys" na mão do jogador
        local hand_cards = Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND,0,nil,0x11f)

        -- Verifica se há cartas "Nephthys" na mão
        if #hand_cards > 0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)

            -- Seleciona uma carta "Nephthys" da mão para destruir como custo
            local sg = hand_cards:Select(tp,1,1,nil)

            -- Destrói a carta selecionada como custo
            Duel.Destroy(sg,REASON_COST) -- Aqui, a destruição acontece como custo

            -- Aqui, você pode adicionar a lógica adicional para lidar com a Invocação Ritual
            local ritual_cards = Duel.GetMatchingGroup(s.ritualfil,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
            if #ritual_cards > 0 then
                local tc = ritual_cards:Select(tp,1,1,nil):GetFirst()
                Duel.RitualSummon(e,tp,tc,nil) -- Invoca o monstro Ritual
                if sg:GetFirst():GetCode() == 61441708 then
                    Duel.Draw(tp,4,REASON_EFFECT) -- Compra 4 cartas se o ID for 61441708
                end
            end
        end
    end
end
