--The Wicked Jabberwocky
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--1 "Crawling Chaos Jabberwock" + 1 "Grimm the Tragic Knight"
	Fusion.AddProcMix(c,true,true,13741175,13741143)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--You can only Special Summon "The Wicked Jabberwocky(s)" once per turn
	c:SetSPSummonOnce(id)
	--While this card is in the Extra Monster Zone, your opponent's monsters cannot target monsters for attacks
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e0a:SetRange(LOCATION_EMZONE)
	e0a:SetTargetRange(0,LOCATION_MZONE)
	e0a:SetValue(function(e,c) return c~=e:GetHandler() end)
	c:RegisterEffect(e0a)	
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0b:SetTargetRange(LOCATION_ONFIELD,0)
	e0b:SetTarget(s.tgtg)
	e0b:SetValue(aux.tgoval)
	c:RegisterEffect(e0b)
	--Special Summon 1 "Black Rabbit Token" (Beast-Warrior/DARK/Level 6/ATK 2500/DEF 2500) to your opponent's field, then you can place 10 Black Soul Counters on this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Send 1 Spell/Trap that mentions "Grimm the Tragic Knight" from your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgdescon)
	e2:SetTarget(s.tgdestg)
	e2:SetOperation(s.tgdesop)
	c:RegisterEffect(e2)	

end

s.counter_place_list={0x118a}
s.listed_series={}
s.listed_names={id,13741175,13741143,13741188}

function s.contactfil(tp)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_ONFIELD end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end

function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.tgtg(e,c)
	return c~=e:GetHandler() 
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13741188,0,TYPES_TOKEN,2500,2500,6,RACE_BEASTWARRIOR,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13741188,0,TYPES_TOKEN,2500,2500,6,RACE_BEASTWARRIOR,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,13741188)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsCanAddCounter(0x118a,10) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			c:AddCounter(0x118a,10)
		end		
	end
end

function s.tgdesconfilter(c)
	return c:IsFaceup() and c:IsCode(13741188)
end

function s.tgdescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(s.tgdesconfilter,tp,0,LOCATION_MZONE,1,nil)
end

function s.tgfilter(c)
	return c:IsSpellTrap() and c:ListsCode(13741143) and c:IsAbleToGrave()
end

function s.tgdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
end

function s.tgdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		local g1=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g1==0 or #g2==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
		local sg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_DESTROY)
		if #sg==2 then
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
