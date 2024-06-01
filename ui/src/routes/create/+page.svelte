<script lang="ts">
	import Typography from "$lib/components/ui/typography.svelte"
    import Input from '$lib/components/ui/input.svelte'
	import Button from "$lib/components/ui/button.svelte"
    import { Image, Close, ArrowRight, ArrowLeft, Edit, Wallet } from 'carbon-icons-svelte'
	import ResponsiveContainer from "$lib/components/responsive-container.svelte"
    import Select from '$lib/components/ui/select/select.svelte'
	import Option from "$lib/components/ui/select/option.svelte"

    let step = $state(3)
    let name = $state('')
    let symbol = $state('')
    let image = $state('')
    let link = $state('')
    let goalAmount = $state(0)
    let maxSupply = $state(0)
    let bondingCurve = $state('linear')
    let durationDays = $state(30)
    let initialAmount = $state(0)

</script>

{#if step === 1}
<form>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>

    <Typography variant="small">Step {step} of 2</Typography>
    <Typography variant="h4">Token details</Typography>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <Input label="Token name" placeholder="Funraising" bind:value={name}>Use only a-z characters, no space</Input>
    <div class="spacer"></div>
    <Input label="Token symbol" placeholder="FUNR" bind:value={symbol}>String, usually a shorter version of the token name</Input>
    <div class="spacer"></div>
    <hr/>
    <div class="horizontal">
        <Button variant="secondary"><Image/>Add image</Button>
        <Typography variant="small">Optional image to be used as an icon for your token</Typography>
    </div>
    <hr/>
    <Input label="Project link" placeholder="https://snaha.net" bind:value={link}>Optional link where people can find more info about the project</Input>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="horizontal buttons">
        <div class="grower"></div>
        <Button variant="secondary" href="/"><Close/>Cancel</Button>
        <Button variant="strong" onclick={() => step = 2}>Continue<ArrowRight/></Button>
    </div>

    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>

</form>
{:else if step === 2}
<form>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <Typography variant="small">Step {step} of 2</Typography>
    <Typography variant="h4">Fundraising parameters</Typography>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <Input label="Fundraising goal" placeholder="10,000" bind:value={goalAmount} type="number" unit="DAI">The amount you are aiming to raise</Input>
    <div class="spacer"></div>
    <Input label="Maximum supply" placeholder="500,000" bind:value={maxSupply} type="number" unit="AHA">The maximum amount of token that can be created</Input>
    <div class="spacer"></div>
    <Select label="Bonding curve" bind:value={bondingCurve}>
        {#snippet helperText()}
            Describes the relationship between the price and supply of an asset
        {/snippet}
        <Option value="linear">Linear</Option>
        <Option value="exponential">Exponential</Option>
    </Select>
    <div class="spacer"></div>
    <hr/>
    <Input label="Fundraising duration" placeholder="30" bind:value={durationDays} unit="Days" controls>Set at time limit to reach your goal</Input>
    <div class="spacer"></div>
    <Input label="Initial funding amount" placeholder="100" bind:value={initialAmount} type="url" unit="DAI">TThe initial amount that you want to invest in this token</Input>
    <hr/>

    <div class="horizontal buttons">
        <Button variant="secondary" onclick={() => step = 1}><ArrowLeft/>Edit token</Button>
        <div class="grower"></div>
        <Button variant="secondary" href="/"><Close/>Cancel</Button>
        <Button variant="strong" onclick={() => step = 3}>Review<ArrowRight/></Button>
    </div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    
</form>

{:else if step === 3}
<form>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <Typography variant="h4">Review</Typography>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <ResponsiveContainer>
        <div class="vertical">
            <Typography variant="small">Token name</Typography>
            <Typography>{name}</Typography>
        </div>
        <div class="vertical">
            <Typography variant="small">Token symbol</Typography>
            <Typography>{symbol}</Typography>
        </div>
    </ResponsiveContainer>
    <ResponsiveContainer>
            <div class="vertical">
            <Typography variant="small">Token image</Typography>
            <Typography>{symbol}</Typography>
        </div>
        <div class="vertical">
            <Typography variant="small">Project link</Typography>
            <Typography>{link}</Typography>
        </div>
    </ResponsiveContainer>
    <hr/>
    <ResponsiveContainer>
        <div class="vertical">
            <Typography variant="small">Fundraising goal</Typography>
            <Typography>{goalAmount}</Typography>
        </div>
        <div class="vertical">
            <Typography variant="small">Duration</Typography>
            <Typography>{durationDays} days</Typography>
        </div>
        <div class="vertical">
            <Typography variant="small">Initial funding amount</Typography>
            <Typography>{initialAmount}</Typography>
        </div>
    </ResponsiveContainer>
    <div class="spacer"></div>
    <div class="vertical">
        <Typography variant="small">Bonding curve</Typography>
        <Typography>{bondingCurve}</Typography>
    </div>
    <div class="spacer"></div>
    <div class="horizontal buttons">
        <Button variant="secondary" onclick={() => step = 1 }><Edit/>Make changes</Button>
        <div class="grower"></div>
    </div>
    <hr/>
    <div class="horizontal buttons">
        <div class="grower">
            <Typography>Please connect a web3 wallet to proceed.</Typography>
        </div>
        <Button variant="strong" onclick={() => step = 3}><Wallet/>Connect wallet</Button>
    </div>

    <pre>{JSON.stringify({
        step,
        name,
        symbol,
        image,
        link,
        goalAmount,
        maxSupply,
        bondingCurve,
        duration: durationDays,
        initialAmount,
    }, undefined, 4)}</pre>

    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>

</form>
{/if}


<style>
form {
    display: flex;
    flex-direction: column;
    width: 50vw;
}
.spacer {
    margin-bottom: var(--padding);
}
.grower {
    flex-grow: 1;
}
.horizontal {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: var(--padding);
}
.vertical {
    display: flex;
    flex-direction: column;
    gap: var(--padding);
    max-width: 33%;
}
.buttons {
    justify-content: stretch;
}
hr {
    appearance: none;
    margin-top: var(--double-padding);
    margin-bottom: var(--double-padding);
    border-width: 1px;
    border-style: solid;
    width: 100%;
    color: var(--colors-low);
}
pre {
    font-family: var(--font-family-monospace);
    color: var(--colors-top);
}
</style>