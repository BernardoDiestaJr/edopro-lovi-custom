--Grand Guignol, Ersatz God of the Vicious Theatre
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 4 Level 6 monsters
	Xyz.AddProcedure(c,nil,6,4)
	--Treated as "Theatre of Darkness - Grand Guignol"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(13741132)
	c:RegisterEffect(e0)
	--Can only target your monster with the highest ATK for attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atcon)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atcon)
	c:RegisterEffect(e2)	
	--Special Summon up to 3 Level 5 or lower LIGHT and/or DARK monsters with different Types, 1 each from your Deck, GY, and banishment
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Detach all materials from this card, and if you do, the activated effect becomes "Add 1 card from your opponent's GY to their hand"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.chcon)
	e4:SetTarget(s.chtg)
	e4:SetOperation(s.chop)
	c:RegisterEffect(e4)


end

s.listed_series={0x41e}
s.listed_names={id,13741132,13741135}

function s.atcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x41e),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.atlimit(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	return not tg:IsContains(c) or c:IsFacedown()
end

function s.spfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND|LOCATION_DECK) or c:IsFaceup())
end

function s.spcheck(sg,e,tp,mg)
	local ct1=sg:GetClassCount(Card.GetRace)
	local ct2=sg:GetClassCount(Card.GetLocation)
	local ct3=#sg
	return ct1==ct3	and ct2==ct3,ct1~=ct3 or ct2~=ct3
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
		if #g>0 then
			ft=math.min(ft,4)
			local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.spcheck,1,tp,HINTMSG_SPSUMMON)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and (re:IsMonsterEffect() or (rc:IsNormalSpellTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local mat_ct=c:GetOverlayCount()
		return mat_ct>0 and c:CheckRemoveOverlayCard(tp,mat_ct,REASON_EFFECT)
			and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e:GetHandler(),tp)
	end
end

function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetOverlayGroup()
	if c:IsRelateToEffect(e) and #mg>0 and Duel.SendtoGrave(mg,REASON_EFFECT)>0 then
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.repop)
	end
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,c,tp):GetFirst()
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Overlay(c,g)
	end
end


function s.attachfilter(c,xyzc,tp)
	return c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end