<script lang="ts">
	import Typography from "$lib/components/ui/typography.svelte"
    import Input from '$lib/components/ui/input.svelte'
	import Button from "$lib/components/ui/button.svelte"
    import { Image, Close, ArrowRight, ArrowLeft, Edit, Wallet, Checkmark, Tsq } from 'carbon-icons-svelte'
	import ResponsiveContainer from "$lib/components/responsive-container.svelte"
    import Select from '$lib/components/ui/select/select.svelte'
	import Option from "$lib/components/ui/select/option.svelte"
    import Chart from "$lib/components/ui/chart.svelte"
    import { polynomial } from "$lib/utils/bonding-curve"
    import { ethers } from 'ethers'
    import { FunFactory__factory, type FunFactory } from '$lib/typechain'
    import { goto } from '$app/navigation'
    import { page } from '$app/stores'

    let step = $state($page.params.step ? parseInt($page.params.step, 10) : 1)
    $inspect(step)
    let name = $state('FUN')
    let symbol = $state('Funraising')
    let image = $state('')
    let link = $state('')
    let goalAmount = $state(10_000)
    let maxSupply = $state(2000)
    let bondingCurve = $state('linear')
    let durationDays = $state(30)
    let initialAmount = $state(0.1)

    let degree = $derived(bondingCurve === 'linear' ? 2 : 3)
    let labels = $derived([...Array(11).keys()].map(value => value * goalAmount / 10))
    let series = $derived([
            {
                fill: true,
                lineTension: 0.3,
                backgroundColor: 'rgba(225, 204,230, .3)',
                borderColor: 'rgb(205, 130, 158)',
                borderCapStyle: 'butt',
                borderDash: [],
                borderDashOffset: 0.0,
                borderJoinStyle: 'miter',
                pointBorderColor: 'rgb(205, 130,1 58)',
                pointBackgroundColor: 'rgb(255, 255, 255)',
                pointBorderWidth: 10,
                pointHoverRadius: 5,
                pointHoverBackgroundColor: 'rgb(0, 0, 0)',
                pointHoverBorderColor: 'rgba(220, 220, 220,1)',
                pointHoverBorderWidth: 2,
                pointRadius: 1,
                pointHitRadius: 10,
                data: labels.map(value => polynomial(value, goalAmount, maxSupply, degree))
            }
        ]
    )

    let confirmDisabled = $state(false)

    async function connectWallet() {
        const provider = new ethers.BrowserProvider((window as any).ethereum)
        const signer = await provider.getSigner()
        gotoPage(4)
    }

    async function makeTransaction() {
        confirmDisabled = true
        
        const raisinToken = '0x702c959708bc19d7c506723A78077b102094CC65'
        const funFactory = '0x5B79C3970886A1F71b82A80c75BE1dD8cDb7BD96'

        const endsAt = Date.now() + (durationDays * 24 * 60 * 60)
        const provider = new ethers.BrowserProvider((window as any).ethereum)
        const signer = await provider.getSigner()
        
        const contract = new ethers.Contract(funFactory, FunFactory__factory.abi, signer) as unknown as FunFactory;
        const tx = await contract.createFun(name, symbol, image, raisinToken, endsAt, maxSupply, goalAmount)
        const result = await tx.wait()
        const address = await result?.getResult()
        console.debug({ address })
        goto(`/token/${address}`)
    }

    function gotoPage(page: number) {
        step = page
        goto(`/create/${step}`)
    }
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
        <Button variant="strong" onclick={() => gotoPage(2)}>Continue<ArrowRight/></Button>
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

    <Chart
        {labels}
        {series}
    />

    <hr/>
    <Input label="Fundraising duration" placeholder="30" bind:value={durationDays} unit="Days" controls>Set at time limit to reach your goal</Input>
    <div class="spacer"></div>
    <Input label="Initial funding amount" placeholder="100" bind:value={initialAmount} type="url" unit="DAI">TThe initial amount that you want to invest in this token</Input>
    <hr/>

    <div class="horizontal buttons">
        <Button variant="secondary" onclick={() => gotoPage(1)}><ArrowLeft/>Edit token</Button>
        <div class="grower"></div>
        <Button variant="secondary" href="/"><Close/>Cancel</Button>
        <Button variant="strong" onclick={() => gotoPage(3)}>Review<ArrowRight/></Button>
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
    <div class="spacer"></div>
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
        <Button variant="secondary" onclick={() => gotoPage(1) }><Edit/>Make changes</Button>
        <div class="grower"></div>
    </div>
    <hr/>
    <div class="horizontal buttons">
        <div class="grower">
            <Typography>Please connect a web3 wallet to proceed.</Typography>
        </div>
        <Button variant="strong" onclick={() => connectWallet()}><Wallet/>Connect wallet</Button>
    </div>

    <!-- <pre>{JSON.stringify({
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
    }, undefined, 4)}</pre> -->

    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>

</form>
{:else if step === 4}
<form>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <div class="spacer"></div>

    <Typography variant="h5">Create token</Typography>
    <Typography>Creating token and buying initial funding amount.</Typography>
    <div class="spacer"></div>
    <div class="spacer"></div>
    <ResponsiveContainer>
        <div class="vertical">
            <Typography variant="small">Buying</Typography>
            <Typography>{initialAmount} {name}</Typography>
        </div>
    </ResponsiveContainer>
    <hr/>
    <div class="horizontal buttons">
        <div class="grower"></div>
        <Button variant="secondary" onclick={() => gotoPage(3)}><Close/>Cancel</Button>
        <Button variant="strong" onclick={() => makeTransaction()} disabled={confirmDisabled}><Checkmark/>Confirm transaction</Button>
    </div>

</form>
{/if}


<style>
form {
    display: flex;
    flex-direction: column;
    max-width: 560px;
    padding: 0 var(--padding);
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
    justify-content: flex-start;
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