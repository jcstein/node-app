import React from "react";
import styles from './style.module.css'
import TextTransition, { presets } from "react-text-transition";

const TEXTS = [
    "boats",
    "trains",
    "bikes",
    "planes",
    "whatever",
];

const Text = () => {
    const [index, setIndex] = React.useState(0);

    React.useEffect(() => {
        const intervalId = setInterval(() =>
            setIndex(index => index + 1),
            2000 // every 3 seconds
        );
        return () => clearTimeout(intervalId);
    }, []);

    return (
        
        <h1 className={styles.subheader}>
            light nodes on
            <TextTransition springConfig={presets.wobbly} inline style={{marginLeft: '4px'}}> 
             {TEXTS[index % TEXTS.length]}
            </TextTransition>
        </h1>
        
    );
};

export default Text;