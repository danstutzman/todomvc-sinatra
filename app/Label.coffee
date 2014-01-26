Label = React.createClass
    handleClick: ->
        console.log("Click")
        this.props.children = "Text After Click"
        this.setState({liked: false})

    render: ->
        console.log("Render")
        return React.DOM.p(
            { ref:"p", onClick: this.handleClick },
            this.props.children
        )

window.Label = Label
module.exports = Label
