import Document, { Html, Head, Main, NextScript } from 'next/document'

class MyDocument extends Document {
  static async getInitialProps(ctx) {
    const initialProps = await Document.getInitialProps(ctx)
    return { ...initialProps }
  }

  render() {
    return (
      <Html>
        <Head>
          <script defer data-domain="quasarapp.xyz" src="https://plausible.io/js/script.js"></script>
          <link rel="icon" href="/icons/favicon.ico" />
          <link rel="icon" href="/icons/favicon.svg" type="image/svg+xml" />
          <meta name="description" content="the first celestia light node macOS app - start your node in 30 seconds" />
        </Head>
        <body>
          <Main />
          <NextScript />
        </body>
      </Html>
    )
  }
}

export default MyDocument
